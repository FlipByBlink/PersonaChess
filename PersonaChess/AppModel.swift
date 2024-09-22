import SwiftUI
import RealityKit
import GroupActivities
import Combine

@MainActor
class AppModel: ObservableObject {
    @Published private(set) var sharedState = SharedState()
    private(set) var entities = Entities()
    @Published private(set) var movingPieces: [Piece.ID] = []
    @Published var isFullSpaceShown: Bool = false
    
    @Published private(set) var groupSession: GroupSession<AppGroupActivity>?
    private var messenger: GroupSessionMessenger?
    private var subscriptions: Set<AnyCancellable> = []
    private var tasks: Set<Task<Void, Never>> = []
    @Published private(set) var spatialSharePlaying: Bool?
    @Published private(set) var myRole: CustomSpatialTemplate.Role? = nil
    
    private let soundFeedback = SoundFeedback()
    @Published var showRecordingRoom: Bool = false
    
    init() {
        self.configureGroupSessions()
        self.setUpEntities()
    }
}

extension AppModel {
    func execute(_ action: Action) {
        guard self.movingPieces.isEmpty else { return }
        switch action {
            case .tapPiece(let tappedPieceBodyEntity):
                guard let tappedPiece: Piece = tappedPieceBodyEntity.parent?.components[Piece.self] else {
                    return
                }
                if let pickedPieceEntity = self.entities.pickedPieceEntity {
                    let pickedPiece: Piece = pickedPieceEntity.components[Piece.self]!
                    if tappedPiece.side == pickedPiece.side {
                        self.sharedState.pieces.pick(tappedPiece.id)
                        self.sharedState.pieces.unpick(pickedPiece.id)
                        self.soundFeedback.select(tappedPieceBodyEntity, self.floorMode)
                    } else {
                        self.sharedState.pieces.appendLog()
                        self.sharedState.pieces.movePiece(pickedPiece.id,
                                                          to: tappedPiece.index)
                        self.sharedState.pieces.removePiece(tappedPiece.id)
                    }
                } else {
                    self.sharedState.pieces.pick(tappedPiece.id)
                    self.soundFeedback.select(tappedPieceBodyEntity, self.floorMode)
                }
            case .tapSquare(let index):
                guard let pickedPieceEntity = self.entities.pickedPieceEntity else {
                    assertionFailure(); return
                }
                self.sharedState.pieces.appendLog()
                self.sharedState.pieces.movePiece(pickedPieceEntity.components[Piece.self]!.id,
                                                  to: index)
            case .drag(let bodyEntity, translation: let dragTranslation):
                guard self.entities.pickedPieceEntity == nil else { return }
                self.sharedState.pieces.drag(bodyEntity, dragTranslation)
            case .drop(let bodyEntity):
                if Pieces.shouldLog(bodyEntity) {
                    self.sharedState.pieces.appendLog()
                }
                self.sharedState.pieces.drop(bodyEntity)
            case .undo:
                self.sharedState.pieces.undo()
            case .reset:
                self.sharedState.pieces.appendLog()
                self.sharedState.pieces.setPreset()
                if self.groupSession != nil { self.sharedState.mode = .sharePlay }
                self.soundFeedback.reset(self.entities.root)
        }
        
        self.applyCurrentStateToEntities()
        self.sendMessage()
    }
    func upScale() {
        self.sharedState.viewScale *= (self.floorMode ? 1.4 : 1.1)
        self.sendMessage()
    }
    func downScale() {
        self.sharedState.viewScale *= (self.floorMode ? 0.75 : 0.9)
        self.sendMessage()
    }
    func raiseBoard() {
        self.sharedState.viewHeight += 50
        self.sendMessage()
    }
    func lowerBoard() {
        self.sharedState.viewHeight -= 50
        self.sendMessage()
    }
    func lowerToFloor() {
        self.sharedState.viewHeight = 0
        self.sendMessage()
    }
    func separateFromFloor() {
        self.sharedState.viewHeight = Size.Point.defaultHeight
        if self.sharedState.viewScale > 3.0 {
            self.sharedState.viewScale = 1.0
        }
        self.sendMessage()
    }
    var upScalable: Bool {
        if self.floorMode {
            self.sharedState.viewScale < 50.0
        } else {
            self.sharedState.viewScale < 5.0
        }
    }
    var downScalable: Bool {
        self.sharedState.viewScale > 0.6
    }
    var isSharePlayStateNotSet: Bool {
        self.groupSession?.state == .joined
        &&
        self.sharedState.mode == .localOnly
    }
    var floorMode: Bool {
        self.isFullSpaceShown
        &&
        self.sharedState.viewHeight == 0
    }
}

private extension AppModel {
    private func setUpEntities() {
        self.applyCurrentStateToEntities()
    }
    private func applyCurrentStateToEntities() {
        for pieceEntity in self.entities.root.children.filter({ $0.components.has(Piece.self) }) {
            let exPiece: Piece = pieceEntity.components[Piece.self]!
            let newPiece: Piece = self.sharedState.pieces[exPiece.id]
            guard exPiece != newPiece else { continue }
            if newPiece.removed {
                pieceEntity.components[Piece.self] = newPiece
                //Fade out by PieceOpacitySystem
            } else {
                if newPiece.dragging {
                    self.entities.applyDraggingPiecePosition(pieceEntity, newPiece)
                } else if exPiece.dragging {
                    Task { @MainActor in
                        self.movingPieces.append(exPiece.id)
                        await self.entities.applyPieceDrop(pieceEntity, newPiece)
                        if exPiece.index != newPiece.index {
                            self.soundFeedback.put(pieceEntity, self.floorMode)
                        }
                        self.movingPieces.removeAll { $0 == exPiece.id }
                    }
                } else {
                    Task { @MainActor in
                        self.entities.disablePieceHoverEffect()
                        self.movingPieces.append(exPiece.id)
                        if exPiece.index != newPiece.index {
                            await self.entities.applyPieceMove(pieceEntity, exPiece, newPiece)
                            self.soundFeedback.put(pieceEntity, self.floorMode)
                        } else {
                            if exPiece.picked != newPiece.picked {
                                await self.entities.applyPiecePickingState(pieceEntity, exPiece, newPiece)
                            }
                        }
                        self.movingPieces.removeAll { $0 == exPiece.id }
                        self.entities.applyPiecePromotion(pieceEntity, newPiece)
                        pieceEntity.components[Piece.self] = newPiece
                        self.entities.activatePieceHoverEffect()
                        Entities.updateInputtablity(pieceEntity)
                    }
                }
            }
        }
    }
}

//MARK: ==== SharePlay ====
extension AppModel {
    var showProgressView: Bool {
        self.groupSession != nil
        &&
        self.sharedState.mode == .localOnly
    }
    private func configureGroupSessions() {
        Task {
            for await groupSession in AppGroupActivity.sessions() {
                self.sharedState.clear()
                self.sharedState.pieces.setPreset()
                self.applyCurrentStateToEntities()
                
                self.groupSession = groupSession
                let messenger = GroupSessionMessenger(session: groupSession)
                self.messenger = messenger
                
                groupSession.$state
                    .sink {
                        if case .invalidated = $0 {
                            self.messenger = nil
                            self.tasks.forEach { $0.cancel() }
                            self.tasks = []
                            self.subscriptions = []
                            self.groupSession = nil
                            self.spatialSharePlaying = nil
                            self.sharedState.pieces.clearAllLog()
                            self.sharedState.pieces.setPreset()
                            self.sharedState.mode = .localOnly
                            self.applyCurrentStateToEntities()
                            self.myRole = nil
                        }
                    }
                    .store(in: &self.subscriptions)
                
                groupSession.$activeParticipants
                    .sink {
                        if $0.count == 1 { self.sharedState.mode = .sharePlay }
                        let newParticipants = $0.subtracting(groupSession.activeParticipants)
                        Task {
                            try? await messenger.send(self.sharedState,
                                                      to: .only(newParticipants))
                        }
                    }
                    .store(in: &self.subscriptions)
                
                self.tasks.insert(
                    Task {
                        for await (message, _) in messenger.messages(of: SharedState.self) {
                            self.receive(message)
                        }
                    }
                )
                
#if os(visionOS)
                self.tasks.insert(
                    Task {
                        if let systemCoordinator = await groupSession.systemCoordinator {
                            for await localParticipantState in systemCoordinator.localParticipantStates {
                                self.spatialSharePlaying = localParticipantState.isSpatial
                            }
                        }
                    }
                )
                
                self.tasks.insert(
                    Task {
                        if let systemCoordinator = await groupSession.systemCoordinator {
                            for await immersionStyle in systemCoordinator.groupImmersionStyle {
                                if immersionStyle != nil {
                                    //TODO: 実装
                                } else {
                                    //TODO: 実装
                                }
                            }
                        }
                    }
                )
                
                self.tasks.insert(
                    Task {
                        if let systemCoordinator = await groupSession.systemCoordinator {
                            var configuration = SystemCoordinator.Configuration()
                            configuration.supportsGroupImmersiveSpace = true
                            configuration.spatialTemplatePreference = .custom(CustomSpatialTemplate())
                            systemCoordinator.configuration = configuration
                            groupSession.join()
                        }
                    }
                )
#else
                groupSession.join()
#endif
            }
        }
    }
    private func sendMessage() {
        Task {
            try? await self.messenger?.send(self.sharedState)
        }
    }
    private func receive(_ message: SharedState) {
        guard message.mode == .sharePlay else { return }
        Task { @MainActor in
            self.sharedState = message
            self.applyCurrentStateToEntities()
        }
    }
    func activateGroupActivity() {
        Task {
            do {
                let result = try await AppGroupActivity().activate()
                switch result {
                    case true: self.sharedState.mode = .sharePlay
                    default: break
                }
            } catch {
                print("Failed to activate activity: \(error)")
            }
        }
    }
#if os(visionOS)
    func set(role: CustomSpatialTemplate.Role?) {
        Task {
            if let systemCoordinator = await self.groupSession?.systemCoordinator {
                if let role {
                    systemCoordinator.assignRole(role)
                } else {
                    systemCoordinator.resignRole()
                }
                self.myRole = role
            }
        }
    }
#endif
}




//======== Reference ========
//Drawing content in a group session | Apple Developer Documentation
//https://developer.apple.com/documentation/groupactivities/drawing_content_in_a_group_session
//
//Design spatial SharePlay experiences - WWDC23 - Videos - Apple Developer
//https://developer.apple.com/videos/play/wwdc2023/10075
//
//Build spatial SharePlay experiences - WWDC23 - Videos - Apple Developer
//https://developer.apple.com/videos/play/wwdc2023/10087
//
//Customizing spatial Persona templates | Apple Developer Documentation
//https://developer.apple.com/documentation/groupactivities/customizing-spatial-persona-templates
