import SwiftUI
import RealityKit
import GroupActivities
import Combine

@MainActor
class AppModel: ObservableObject {
    @Published private(set) var activityState = ActivityState()
    private(set) var rootEntity = Entity()
    @Published private(set) var movingPieces: [Piece.ID] = []
    
    @Published private(set) var groupSession: GroupSession<AppGroupActivity>?
    private var messenger: GroupSessionMessenger?
    private var subscriptions: Set<AnyCancellable> = []
    private var tasks: Set<Task<Void, Never>> = []
    @Published private(set) var spatialSharePlaying: Bool?
    
    private let soundFeedback = SoundFeedback()
    
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
            case .undo:
                if let previousChessValue = self.activityState.chess.log.popLast() {
                    self.activityState.chess.latest = previousChessValue
                } else {
                    assertionFailure()
                }
            case .reset:
                self.activityState.chess.appendLog()
                self.soundFeedback.reset(self.rootEntity)
                self.activityState.chess.setPreset()
                if self.groupSession != nil { self.activityState.mode = .sharePlay }
        }
        self.applyLatestChessToEntities(animation: action != .undo)
        self.sendMessage()
    }
    func upScale() {
        self.activityState.viewScale *= (self.floorMode ? 1.4 : 1.1)
        self.sendMessage()
    }
    func downScale() {
        self.activityState.viewScale *= (self.floorMode ? 0.75 : 0.9)
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
    func lowerToFloor() {
        self.activityState.viewHeight = 0
        self.sendMessage()
    }
    func separateFromFloor() {
        self.activityState.viewHeight = Size.Point.defaultHeight
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
    var isSharePlayStateNotSet: Bool {
        self.groupSession?.state == .joined
        &&
        self.activityState.mode == .localOnly
    }
    var floorMode: Bool {
        self.activityState.viewHeight == 0
    }
}

private extension AppModel {
    private func setUpEntities() {
        self.activityState.chess.setPreset()
        self.activityState.chess.latest.forEach {
            self.rootEntity.addChild(PieceEntity.load($0))
        }
        self.applyLatestChessToEntities(animation: false)
    }
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
                            translation.y = latestPiece.picked ? Size.Meter.pickedOffset : 0
                            let duration: TimeInterval = animation ? 0.6 : 0
                            let pieceBodyEntity = pieceEntity.findEntity(named: "body")!
                            pieceBodyEntity.move(to: .init(translation: translation),
                                                 relativeTo: self.rootEntity,
                                                 duration: duration)
                            try? await Task.sleep(for: .seconds(duration))
                        }
                    }
                    pieceEntity.findEntity(named: "promotionMark")?.isEnabled = latestPiece.promotion
                    pieceEntity.components[Piece.self] = latestPiece
                    self.activatePieceHoverEffect()
                    self.movingPieces.removeAll { $0 == piece.id }
                }
            }
        }
    }
    private func raisePiece(_ entity: Entity, _ index: Index, _ animation: Bool) async {
        var translation = index.position
        translation.y = Size.Meter.pickedOffset
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
    var showProgressView: Bool {
        self.groupSession != nil
        &&
        self.activityState.mode == .localOnly
    }
    private func configureGroupSessions() {
        Task {
            for await groupSession in AppGroupActivity.sessions() {
                self.activityState.clear()
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
                            self.spatialSharePlaying = nil
                            self.activityState.chess.clearLog()
                            self.activityState.chess.setPreset()
                            self.activityState.mode = .localOnly
                            self.applyLatestChessToEntities(animation: false)
                        }
                    }
                    .store(in: &self.subscriptions)
                
                groupSession.$activeParticipants
                    .sink {
                        if $0.count == 1 { self.activityState.mode = .sharePlay }
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
                                self.spatialSharePlaying = localParticipantState.isSpatial
                            }
                        }
                    }
                )
#endif
                groupSession.join()
            }
        }
    }
    private func sendMessage() {
        Task {
            try? await self.messenger?.send(self.activityState)
        }
    }
    private func receive(_ message: ActivityState) {
        guard message.mode == .sharePlay else { return }
        Task { @MainActor in
            self.activityState = message
            self.applyLatestChessToEntities()
        }
    }
    func activateGroupActivity() {
        Task {
            do {
                let result = try await AppGroupActivity().activate()
                switch result {
                    case true: self.activityState.mode = .sharePlay
                    default: break
                }
            } catch {
                print("Failed to activate activity: \(error)")
            }
        }
    }
}

//Ref: Drawing content in a group session | Apple Developer Documentation
//https://developer.apple.com/documentation/groupactivities/drawing_content_in_a_group_session
//Ref: Design spatial SharePlay experiences - WWDC23 - Videos - Apple Developer
//https://developer.apple.com/videos/play/wwdc2023/10075
//Ref: Build spatial SharePlay experiences - WWDC23 - Videos - Apple Developer
//https://developer.apple.com/videos/play/wwdc2023/10087
