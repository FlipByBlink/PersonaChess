import SwiftUI
import RealityKit
import GroupActivities
import Combine

@MainActor
class AppModel: ObservableObject {
    @Published private(set) var activityState: ActivityState = .init()
    private(set) var rootEntity: Entity = .init()
    private var moving: Bool = false
    
    @Published private(set) var groupSession: GroupSession<AppGroupActivity>?
    private var messenger: GroupSessionMessenger?
    private var subscriptions = Set<AnyCancellable>()
    private var tasks = Set<Task<Void, Never>>()
    
    private let soundFeedback: SoundFeedback = .init()
}

extension AppModel {
    func setUpEntities() {
        self.activityState.chess.latest = FixedValue.preset
        self.activityState.chess.latest.forEach {
            self.rootEntity.addChild(PieceEntity.load($0))
        }
        self.applyLatestChessToEntities(animation: false)
    }
    func execute(_ action: Action) {
        guard self.moving == false else { return }
        switch action {
            case .tapPiece(let tappedPieceEntity):
                guard let tappedPiece = tappedPieceEntity.parent?.components[Piece.self] else {
                    return
                }
                if self.activityState.chess.latest.contains(where: { $0.picked }) {
                    guard let pickedPieceEntity = self.pickedPieceEntity() else {
                        assertionFailure(); return
                    }
                    if tappedPieceEntity == pickedPieceEntity {
                        self.activityState.chess.unpick(tappedPiece.id)
                    } else {
                        let pickedPiece = pickedPieceEntity.components[Piece.self]!
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
                self.activityState.chess.latest = FixedValue.preset
        }
        self.applyLatestChessToEntities(animation: action != .back)
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
}

private extension AppModel {
    private func pickedPieceEntity() -> Entity? {
        self.rootEntity.children.first { $0.components[Piece.self]?.picked == true }
    }
    private func applyLatestChessToEntities(animation: Bool = true) {
        for pieceEntity in self.rootEntity.children.filter({ $0.components.has(Piece.self) }) {
            let piece = pieceEntity.components[Piece.self]!
            let latestPiece = self.activityState.chess.latest.first { $0.id == piece.id }!
            guard piece != latestPiece else { continue }
            if latestPiece.removed {
                pieceEntity.components[Piece.self] = latestPiece
            } else {
                Task { @MainActor in
                    self.moving = true
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
                    self.moving = false
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
    func configureGroupSession(_ groupSession: GroupSession<AppGroupActivity>) {
        self.execute(.reset)
        
        self.groupSession = groupSession
        let messenger = GroupSessionMessenger(session: groupSession)
        self.messenger = messenger
        
        groupSession.$state
            .sink { state in
                if case .invalidated = state {
                    self.groupSession = nil
                    self.execute(.reset)
                }
            }
            .store(in: &subscriptions)
        
        groupSession.$activeParticipants
            .sink { activeParticipants in
                let newParticipants = activeParticipants.subtracting(groupSession.activeParticipants)
                Task {
                    try? await messenger.send(self.activityState,
                                              to: .only(newParticipants))
                }
            }
            .store(in: &subscriptions)
        
        let task = Task {
            for await (message, _) in messenger.messages(of: ActivityState.self) {
                Task { @MainActor in
                    self.receive(message)
                }
            }
        }
        self.tasks.insert(task)
        
#if os(visionOS)
        //Task {
        //    if let systemCoordinator = await groupSession.systemCoordinator {
        //        for await localParticipantState in systemCoordinator.localParticipantStates {
        //            if localParticipantState.isSpatial {
        //                // Start syncing spacial-actions
        //            } else {
        //                // Stop syncing spacial-actions
        //            }
        //        }
        //    }
        //}
        
        //Task {
        //    if let systemCoordinator = await groupSession.systemCoordinator {
        //        for await immersionStyle in systemCoordinator.groupImmersionStyle {
        //            if let immersionStyle {
        //                // Open an immersive space with the same immersion style
        //            } else {
        //                // Dismiss the immersive space
        //            }
        //        }
        //    }
        //}
        
        Task {
            if let systemCoordinator = await groupSession.systemCoordinator {
                var configuration = SystemCoordinator.Configuration()
                configuration.spatialTemplatePreference = .none
                //configuration.supportsGroupImmersiveSpace = true
                systemCoordinator.configuration = configuration
                groupSession.join()
            }
        }
#else
        groupSession.join()
#endif
    }
    func restartGroupActivity() {
        self.execute(.reset)
        
        self.messenger = nil
        self.tasks.forEach { $0.cancel() }
        self.tasks = []
        self.subscriptions = []
        if self.groupSession != nil {
            self.groupSession?.leave()
            self.groupSession = nil
            self.activateGroupActivity()
        }
    }
    private func sendMessage() {
        Task {
            try? await self.messenger?.send(self.activityState)
        }
    }
    private func receive(_ message: ActivityState) {
        self.activityState = message
        self.applyLatestChessToEntities()
    }
}
