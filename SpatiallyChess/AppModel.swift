import SwiftUI
import RealityKit
import GroupActivities
import Combine

@MainActor
class AppModel: ObservableObject {
    @Published private(set) var activityState: ActivityState = .init()
    private(set) var rootEntity: Entity = .init()
    @Published private(set) var movingPieces: [Piece.ID] = []
    
    @Published private(set) var groupSession: GroupSession<AppGroupActivity>?
    @Published private(set) var isSpatial: Bool = false
    private var messenger: GroupSessionMessenger?
    private var subscriptions = Set<AnyCancellable>()
    private var tasks = Set<Task<Void, Never>>()
    
    private let soundFeedback: SoundFeedback = .init()
    
    init() {
        self.handleGroupSession()
    }
}

extension AppModel {
    func setUpEntities() {
        self.activityState.chess.setPreset()
        self.activityState.chess.latest.forEach {
            self.rootEntity.addChild(PieceEntity.load($0))
        }
        self.applyLatestChessToEntities(animation: false)
    }
    func execute(_ action: Action) {
        guard self.movingPieces.isEmpty else { return }
        switch action {
            case .tapPiece(let tappedPieceEntity):
                guard let tappedPiece: Piece = tappedPieceEntity.parent?.components[Piece.self] else {
                    return
                }
                if self.activityState.chess.latest.contains(where: { $0.picked }) {
                    guard let pickedPieceEntity = self.pickedPieceEntity() else {
                        assertionFailure(); return
                    }
                    if tappedPieceEntity == pickedPieceEntity {
                        self.activityState.chess.unpick(tappedPiece.id)
                    } else {
                        let pickedPiece: Piece = pickedPieceEntity.components[Piece.self]!
                        if tappedPiece.side == pickedPiece.side {
                            self.activityState.chess.pick(tappedPiece.id)
                            self.activityState.chess.unpick(pickedPiece.id)
                            self.soundFeedback.select(tappedPieceEntity)
                        } else {
                            self.activityState.chess.appendLog()
                            self.activityState.chess.movePiece(pickedPiece.id,
                                                               to: tappedPiece.index)
                            self.activityState.chess.removePiece(tappedPiece.id)
                        }
                    }
                } else {
                    self.activityState.chess.pick(tappedPiece.id)
                    self.soundFeedback.select(tappedPieceEntity)
                }
            case .tapSquare(let index):
                self.activityState.chess.appendLog()
                self.activityState.chess.movePiece(self.pickedPieceEntity()!.components[Piece.self]!.id,
                                                   to: index)
            case .back:
                if let previousChessValue = self.activityState.chess.log.popLast() {
                    self.activityState.chess.latest = previousChessValue
                } else {
                    assertionFailure()
                }
            case .reset:
                self.activityState.chess.appendLog()
                self.soundFeedback.reset(self.rootEntity)
                self.activityState.chess.setPreset()
        }
        self.applyLatestChessToEntities(animation: action != .back)
        self.sendMessage()
    }
    func enterFullSpaceWithEveryone() {
        self.activityState.preferredScene = .fullSpace
        self.sendMessage()
    }
    func exitFullSpaceWithEveryone() {
        self.activityState.preferredScene = .window
        self.sendMessage()
    }
    func upScale() {
        self.activityState.viewScale += 0.07
        self.sendMessage()
    }
    func downScale() {
        self.activityState.viewScale -= 0.07
        self.sendMessage()
    }
    func raiseBoard() {
        self.activityState.viewHeight += 50
        self.sendMessage()
    }
    func lowerBoard() {
        self.activityState.viewHeight -= 50
        self.sendMessage()
    }
    func rotateBoard() {
        self.activityState.boardAngle += 90
        self.sendMessage()
    }
    func expandToolbar(_ position: ToolbarPosition) {
        self.activityState.expandedToolbar.append(position)
        self.sendMessage()
    }
    func closeToolbar(_ position: ToolbarPosition) {
        self.activityState.expandedToolbar.removeAll { $0 == position }
        self.sendMessage()
    }
}

private extension AppModel {
    private func pickedPieceEntity() -> Entity? {
        self.rootEntity.children.first { $0.components[Piece.self]?.picked == true }
    }
    private func applyLatestChessToEntities(animation: Bool = true) {
        for pieceEntity in self.rootEntity.children.filter({ $0.components.has(Piece.self) }) {
            let piece: Piece = pieceEntity.components[Piece.self]!
            let latestPiece: Piece = self.activityState.chess.latest.first { $0.id == piece.id }!
            guard piece != latestPiece else { continue }
            if latestPiece.removed {
                pieceEntity.components[Piece.self] = latestPiece
            } else {
                Task { @MainActor in
                    self.movingPieces.append(piece.id)
                    self.disablePieceHoverEffect()
                    if piece.index != latestPiece.index {
                        if !piece.picked {
                            await self.raisePiece(pieceEntity, piece.index, animation)
                        }
                        let duration: TimeInterval = animation ? 1 : 0
                        pieceEntity.move(to: .init(translation: latestPiece.index.position),
                                         relativeTo: self.rootEntity,
                                         duration: duration)
                        try? await Task.sleep(for: .seconds(duration))
                        await self.lowerPiece(pieceEntity, latestPiece.index, animation)
                    } else {
                        if piece.picked != latestPiece.picked {
                            var translation = piece.index.position
                            translation.y = latestPiece.picked ? FixedValue.pickedOffset : 0
                            let duration: TimeInterval = animation ? 0.6 : 0
                            let pieceBodyEntity = pieceEntity.findEntity(named: "body")!
                            pieceBodyEntity.move(to: .init(translation: translation),
                                                 relativeTo: self.rootEntity,
                                                 duration: duration)
                            try? await Task.sleep(for: .seconds(duration))
                        }
                    }
                    pieceEntity.components[Piece.self] = latestPiece
                    self.activatePieceHoverEffect()
                    self.movingPieces.removeAll { $0 == piece.id }
                }
            }
        }
    }
    private func raisePiece(_ entity: Entity, _ index: Index, _ animation: Bool) async {
        var translation = index.position
        translation.y = FixedValue.pickedOffset
        let duration: TimeInterval = animation ? 0.6 : 0
        let pieceBodyEntity = entity.findEntity(named: "body")!
        pieceBodyEntity.move(to: .init(translation: translation),
                             relativeTo: self.rootEntity,
                             duration: duration)
        try? await Task.sleep(for: .seconds(duration))
    }
    private func lowerPiece(_ entity: Entity, _ index: Index, _ animation: Bool) async {
        let duration: TimeInterval = animation ? 0.7 : 0
        let pieceBodyEntity = entity.findEntity(named: "body")!
        pieceBodyEntity.move(to: .init(translation: index.position),
                             relativeTo: self.rootEntity,
                             duration: duration)
        try? await Task.sleep(for: .seconds(duration))
        if animation { self.soundFeedback.put(entity) }
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
    func activateGroupActivity() {
        Task {
            do {
                _ = try await AppGroupActivity().activate()
            } catch {
                print("Failed to activate activity: \(error)")
            }
        }
    }
    func handleGroupSession() {
        Task {
            for await session in AppGroupActivity.sessions() {
                self.configureGroupSession(session)
            }
        }
    }
    private func configureGroupSession(_ groupSession: GroupSession<AppGroupActivity>) {
        self.activityState.chess.clearLog()
        self.activityState.chess.setPreset()
        self.applyLatestChessToEntities(animation: false)
        
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
                    self.activityState.chess.clearLog()
                    self.activityState.chess.setPreset()
                    self.applyLatestChessToEntities(animation: false)
                }
            }
            .store(in: &self.subscriptions)
        
        groupSession.$activeParticipants
            .sink {
                let newParticipants = $0.subtracting(groupSession.activeParticipants)
                Task {
                    try? await messenger.send(self.activityState,
                                              to: .only(newParticipants))
                }
            }
            .store(in: &self.subscriptions)
        
        self.tasks.insert(
            Task {
                for await (message, _) in messenger.messages(of: ActivityState.self) {
                    self.receive(message)
                }
            }
        )
        
#if os(visionOS)
        self.tasks.insert(
            Task {
                if let systemCoordinator = await groupSession.systemCoordinator {
                    for await localParticipantState in systemCoordinator.localParticipantStates {
                        self.isSpatial = localParticipantState.isSpatial
                    }
                }
            }
        )
        
        //self.tasks.insert(
        //    Task {
        //        if let systemCoordinator = await groupSession.systemCoordinator {
        //            for await immersionStyle in systemCoordinator.groupImmersionStyle {
        //                if immersionStyle != nil {
        //                    // Open an immersive space with the same immersion style
        //                } else {
        //                    // Dismiss the immersive space
        //                }
        //            }
        //        }
        //    }
        //)
        
        self.tasks.insert(
            Task {
                if let systemCoordinator = await groupSession.systemCoordinator {
                    var configuration = SystemCoordinator.Configuration()
                    //configuration.spatialTemplatePreference = .none
                    configuration.supportsGroupImmersiveSpace = true
                    systemCoordinator.configuration = configuration
                    groupSession.join()
                }
            }
        )
#else
        groupSession.join()
#endif
    }
    //func restartGroupActivity() {
    //    self.activityState.chess.clearLog()
    //    self.activityState.chess.setPreset()
    //    self.applyLatestChessToEntities(animation: false)
    //    
    //    self.messenger = nil
    //    self.tasks.forEach { $0.cancel() }
    //    self.tasks = []
    //    self.subscriptions = []
    //    if self.groupSession != nil {
    //        self.groupSession?.leave()
    //        self.groupSession = nil
    //        self.activateGroupActivity()
    //    }
    //}
    private func sendMessage() {
        Task {
            try? await self.messenger?.send(self.activityState)
        }
    }
    private func receive(_ message: ActivityState) {
        guard !message.chess.log.isEmpty else { return }
        Task { @MainActor in
            self.activityState = message
            self.applyLatestChessToEntities()
        }
    }
}

//Ref: Drawing content in a group session | Apple Developer Documentation
//https://developer.apple.com/documentation/groupactivities/drawing_content_in_a_group_session
//Ref: Design spatial SharePlay experiences - WWDC23 - Videos - Apple Developer
//https://developer.apple.com/videos/play/wwdc2023/10075
//Ref: Build spatial SharePlay experiences - WWDC23 - Videos - Apple Developer
//https://developer.apple.com/videos/play/wwdc2023/10087
