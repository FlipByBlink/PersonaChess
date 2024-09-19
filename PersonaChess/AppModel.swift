import SwiftUI
import RealityKit
import GroupActivities
import Combine

@MainActor
class AppModel: ObservableObject {
    @Published private(set) var sharedState = SharedState()
    private(set) var rootEntity = Entity()
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
            case .tapPiece(let tappedPieceEntity):
                guard let tappedPiece: Piece = tappedPieceEntity.parent?.components[Piece.self] else {
                    return
                }
                if self.sharedState.chess.latest.contains(where: { $0.picked }) {
                    guard let pickedPieceEntity = self.pickedPieceEntity() else {
                        assertionFailure(); return
                    }
                    if tappedPieceEntity == pickedPieceEntity {
                        self.sharedState.chess.unpick(tappedPiece.id)
                    } else {
                        let pickedPiece: Piece = pickedPieceEntity.components[Piece.self]!
                        if tappedPiece.side == pickedPiece.side {
                            self.sharedState.chess.pick(tappedPiece.id)
                            self.sharedState.chess.unpick(pickedPiece.id)
                            self.soundFeedback.select(tappedPieceEntity, self.floorMode)
                        } else {
                            self.sharedState.chess.appendLog()
                            self.sharedState.chess.movePiece(pickedPiece.id,
                                                             to: tappedPiece.index)
                            self.sharedState.chess.removePiece(tappedPiece.id)
                        }
                    }
                } else {
                    self.sharedState.chess.pick(tappedPiece.id)
                    self.soundFeedback.select(tappedPieceEntity, self.floorMode)
                }
            case .tapSquare(let index):
                self.sharedState.chess.appendLog()
                self.sharedState.chess.movePiece(self.pickedPieceEntity()!.components[Piece.self]!.id,
                                                 to: index)
            case .undo:
                if let previousChessValue = self.sharedState.chess.log.popLast() {
                    self.sharedState.chess.latest = previousChessValue
                } else {
                    assertionFailure()
                }
            case .reset:
                self.sharedState.chess.appendLog()
                self.soundFeedback.reset(self.rootEntity)
                self.sharedState.chess.setPreset()
                if self.groupSession != nil { self.sharedState.mode = .sharePlay }
            case .drag(let bodyEntity, translation: let dragTranslation):
                self.sharedState.chess.drag(bodyEntity, dragTranslation)
            case .drop(let bodyEntity):
                self.sharedState.chess.appendLog()
                self.sharedState.chess.drop(bodyEntity)
        }
        
        self.applyLatestChessToEntities()
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
        self.sharedState.chess.setPreset()
        self.sharedState.chess.latest.forEach {
            self.rootEntity.addChild(PieceEntity.load($0))
        }
        self.applyLatestChessToEntities()
    }
    private func pickedPieceEntity() -> Entity? {
        self.rootEntity.children.first { $0.components[Piece.self]?.picked == true }
    }
    private func applyLatestChessToEntities() {
        for pieceEntity in self.rootEntity.children.filter({ $0.components.has(Piece.self) }) {
            let exPiece: Piece = pieceEntity.components[Piece.self]!
            let newPiece: Piece = self.sharedState.chess.latest.first { $0.id == exPiece.id }!
            guard exPiece != newPiece else { continue }
            if newPiece.removed {
                pieceEntity.components[Piece.self] = newPiece
                //Fade out by PieceOpacitySystem
            } else {
                if newPiece.dragging {
                    pieceEntity.findEntity(named: "body")!.position.y = newPiece.bodyYOffset
                    pieceEntity.setPosition(newPiece.position,
                                            relativeTo: self.rootEntity)
                    pieceEntity.components[Piece.self] = newPiece
                } else if exPiece.dragging {
                    let duration = 0.5
                    pieceEntity.findEntity(named: "body")!.move(to: Transform(),
                                                                relativeTo: pieceEntity,
                                                                duration: duration)
                    pieceEntity.move(to: Transform(translation: newPiece.position),
                                     relativeTo: self.rootEntity,
                                     duration: duration)
                    pieceEntity.findEntity(named: "promotionMark")?.isEnabled = newPiece.promotion
                    pieceEntity.components[Piece.self] = newPiece
                } else {
                    Task { @MainActor in
                        self.movingPieces.append(exPiece.id)
                        self.disablePieceHoverEffect()
                        if exPiece.index != newPiece.index {
                            if !exPiece.picked {
                                await self.raisePiece(pieceEntity, exPiece.index)
                            }
                            let duration: TimeInterval = 1
                            pieceEntity.move(to: .init(translation: newPiece.index.position),
                                             relativeTo: self.rootEntity,
                                             duration: duration)
                            try? await Task.sleep(for: .seconds(duration))
                            await self.lowerPiece(pieceEntity, newPiece.index)
                        } else {
                            if exPiece.picked != newPiece.picked {
                                var translation = exPiece.index.position
                                translation.y = newPiece.picked ? Size.Meter.pickedOffset : 0
                                let duration: TimeInterval = 0.6
                                let pieceBodyEntity = pieceEntity.findEntity(named: "body")!
                                pieceBodyEntity.move(to: .init(translation: translation),
                                                     relativeTo: self.rootEntity,
                                                     duration: duration)
                                try? await Task.sleep(for: .seconds(duration))
                            }
                        }
                        pieceEntity.findEntity(named: "promotionMark")?.isEnabled = newPiece.promotion
                        pieceEntity.components[Piece.self] = newPiece
                        self.activatePieceHoverEffect()
                        self.movingPieces.removeAll { $0 == exPiece.id }
                        self.updateInputtablity(pieceEntity)
                    }
                }
            }
        }
    }
    private func raisePiece(_ entity: Entity, _ index: Index) async {
        var translation = index.position
        translation.y = Size.Meter.pickedOffset
        let duration: TimeInterval = 0.6
        let pieceBodyEntity = entity.findEntity(named: "body")!
        pieceBodyEntity.move(to: .init(translation: translation),
                             relativeTo: self.rootEntity,
                             duration: duration)
        try? await Task.sleep(for: .seconds(duration))
    }
    private func lowerPiece(_ entity: Entity, _ index: Index) async {
        let duration: TimeInterval = 0.7
        let pieceBodyEntity = entity.findEntity(named: "body")!
        pieceBodyEntity.move(to: .init(translation: index.position),
                             relativeTo: self.rootEntity,
                             duration: duration)
        try? await Task.sleep(for: .seconds(duration))
    }
    private func updateInputtablity(_ pieceEntity: Entity) {
        let piece: Piece = pieceEntity.components[Piece.self]!
        let pieceBodyEntity = pieceEntity.findEntity(named: "body")!
        if piece.picked {
            pieceBodyEntity.components.remove(CollisionComponent.self)
            pieceBodyEntity.components.remove(InputTargetComponent.self)
        } else {
            pieceBodyEntity.components.set([
                PieceEntity.collisionComponent(entity: pieceEntity),
                InputTargetComponent()
            ])
        }
    }
#if os(visionOS)
    private func disablePieceHoverEffect() {
        self.rootEntity
            .children
            .filter { $0.components.has(Piece.self) }
            .forEach { $0.findEntity(named: "body")!.components.remove(HoverEffectComponent.self) }
    }
    private func activatePieceHoverEffect() {
        self.rootEntity
            .children
            .filter { $0.components.has(Piece.self) }
            .forEach { $0.findEntity(named: "body")!.components.set(HoverEffectComponent()) }
    }
#else
    private func disablePieceHoverEffect() {}
    private func activatePieceHoverEffect() {}
#endif
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
                self.sharedState.chess.setPreset()
                self.applyLatestChessToEntities()
                
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
                            self.sharedState.chess.clearLog()
                            self.sharedState.chess.setPreset()
                            self.sharedState.mode = .localOnly
                            self.applyLatestChessToEntities()
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
            self.applyLatestChessToEntities()
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
