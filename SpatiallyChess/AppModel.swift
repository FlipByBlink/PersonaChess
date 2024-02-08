import SwiftUI
import RealityKit
import GroupActivities
import Combine

@MainActor
class AppModel: ObservableObject {
    @Published private(set) var chessState: ChessState = .init()
    private(set) var rootEntity: Entity = .init()
    private var moving: Bool = false
    @Published private(set) var boardAngle: Double = 0
    @Published private(set) var viewHeight: Double = 1000
    @Published private(set) var scale: Double = 1
    
    @Published private(set) var groupSession: GroupSession<AppGroupActivity>?
    private var messenger: GroupSessionMessenger?
    private var subscriptions = Set<AnyCancellable>()
    private var tasks = Set<Task<Void, Never>>()
    
    private let soundFeedback: SoundFeedback = .init()
}

extension AppModel {
    func setUpEntities() {
        self.chessState.latestSituation = FixedValue.preset
        self.chessState.latestSituation.forEach {
            self.rootEntity.addChild(PieceEntity.load($0))
        }
        self.applyLatestSituationToEntities(animation: false)
    }
    func executeAction(_ action: Action) {
        guard self.moving == false else { return }
        switch action {
            case .tapPiece(let tappedPieceEntity):
                guard let tappedPiece = tappedPieceEntity.parent?.components[Piece.self] else {
                    return
                }
                if self.chessState.latestSituation.contains(where: { $0.picked }) {
                    guard let pickedPieceEntity = self.pickedPieceEntity() else {
                        assertionFailure(); return
                    }
                    if tappedPieceEntity == pickedPieceEntity {
                        self.chessState.unpick(tappedPiece.id)
                    } else {
                        let pickedPiece = pickedPieceEntity.components[Piece.self]!
                        if tappedPiece.side == pickedPiece.side {
                            self.chessState.pick(tappedPiece.id)
                            self.chessState.unpick(pickedPiece.id)
                            self.soundFeedback.select()
                        } else {
                            self.chessState.logPreviousSituation()
                            self.chessState.movePiece(pickedPiece.id,
                                                     to: tappedPiece.index)
                            self.chessState.removePiece(tappedPiece.id)
                        }
                    }
                } else {
                    self.chessState.pick(tappedPiece.id)
                    self.soundFeedback.select()
                }
            case .tapSquare(let index):
                self.chessState.logPreviousSituation()
                self.chessState.movePiece(self.pickedPieceEntity()!.components[Piece.self]!.id,
                                         to: index)
            case .back:
                if let oldChessState = self.chessState.log.popLast() {
                    self.chessState.latestSituation = oldChessState
                } else {
                    assertionFailure()
                }
            case .reset:
                self.chessState.logPreviousSituation()
                self.soundFeedback.reset()
                self.chessState.latestSituation = FixedValue.preset
        }
        self.applyLatestSituationToEntities(animation: action != .back)
        self.sendMessage()
    }
    func upScale() {
        self.scale += 0.07
    }
    func downScale() {
        self.scale -= 0.07
    }
    func raiseBoard() {
        self.viewHeight += 50
    }
    func lowerBoard() {
        self.viewHeight -= 50
    }
    func rotateBoard() {
        self.boardAngle += 90
    }
}

private extension AppModel {
    private func pickedPieceEntity() -> Entity? {
        self.rootEntity.children.first { $0.components[Piece.self]?.picked == true }
    }
    private func applyLatestSituationToEntities(animation: Bool = true) {
        self.rootEntity
            .children
            .filter { $0.components.has(Piece.self) }
            .forEach { pieceEntity in
                let piece = pieceEntity.components[Piece.self]!
                let latestPiece = self.chessState.latestSituation.first { $0.id == piece.id }!
                if piece != latestPiece {
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
        if animation { self.soundFeedback.put() }
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
    func sendMessage() {
        Task {
            try? await self.messenger?.send(self.chessState)
        }
    }
    private func receive(_ newChessState: ChessState) {
        self.chessState = newChessState
        self.applyLatestSituationToEntities()
    }
}
