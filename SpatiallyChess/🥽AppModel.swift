import SwiftUI
import RealityKit
import GroupActivities
import Combine

@MainActor
class 🥽AppModel: ObservableObject {
    @Published private(set) var gameState: GameState = .init()
    private(set) var rootEntity: Entity = .init()
    private var moving: Bool = false
    @Published private(set) var boardAngle: Double = 0
    @Published private(set) var viewHeight: Double = 1000
    @Published var scale: Double = 1
    
    @Published private(set) var groupSession: GroupSession<👤GroupActivity>?
    private var messenger: GroupSessionMessenger?
    private var subscriptions = Set<AnyCancellable>()
    private var tasks = Set<Task<Void, Never>>()
    
    private let soundEffect: 📢SoundEffect = .init()
}

extension 🥽AppModel {
    func setUpEntities() {
        self.gameState.latestSituation = FixedValue.preset
        self.gameState.latestSituation.forEach {
            self.rootEntity.addChild(🧩PieceEntity.load($0))
        }
        self.applyLatestSituationToEntities(animation: false)
    }
    func executeAction(_ action: Action) {
        guard self.moving == false else { return }
        switch action {
            case .tapPiece(let tappedPieceEntity):
                guard let tappedPieceState = tappedPieceEntity.parent?.components[PieceStateComponent.self] else {
                    return
                }
                if self.gameState.latestSituation.contains(where: { $0.picked }) {
                    guard let pickedPieceEntity = self.pickedPieceEntity() else {
                        assertionFailure(); return
                    }
                    if tappedPieceEntity == pickedPieceEntity {
                        self.gameState.unpick(tappedPieceState.id)
                    } else {
                        let pickedPieceState = pickedPieceEntity.components[PieceStateComponent.self]!
                        if tappedPieceState.side == pickedPieceState.side {
                            self.gameState.pick(tappedPieceState.id)
                            self.gameState.unpick(pickedPieceState.id)
                        } else {
                            self.gameState.logPreviousSituation()
                            self.gameState.movePiece(pickedPieceState.id,
                                                     to: tappedPieceState.index)
                            self.gameState.removePiece(tappedPieceState.id)
                        }
                    }
                } else {
                    self.gameState.pick(tappedPieceState.id)
                }
            case .tapSquare(let index):
                self.gameState.logPreviousSituation()
                self.gameState
                    .movePiece(self.pickedPieceEntity()!.components[PieceStateComponent.self]!.id,
                               to: index)
            case .back:
                if let oldGameState = self.gameState.log.popLast() {
                    self.gameState.latestSituation = oldGameState
                } else {
                    assertionFailure()
                }
            case .reset:
                self.gameState.logPreviousSituation()
                self.soundEffect.secondAction()
                self.gameState.latestSituation = FixedValue.preset
        }
        self.applyLatestSituationToEntities(animation: action != .back)
        self.sendMessage()
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

private extension 🥽AppModel {
    private func pickedPieceEntity() -> Entity? {
        self.rootEntity.children.first { $0.components[PieceStateComponent.self]?.picked == true }
    }
    private func applyLatestSituationToEntities(animation: Bool = true) {
        self.rootEntity
            .children
            .filter { $0.components.has(PieceStateComponent.self) }
            .forEach { pieceEntity in
                let entityPieceState = pieceEntity.components[PieceStateComponent.self]!
                let latestPieceState = {
                    self.gameState
                        .latestSituation
                        .first { $0.id == entityPieceState.id }!
                }()
                if entityPieceState != latestPieceState {
                    if latestPieceState.removed {
                        pieceEntity.components[PieceStateComponent.self] = latestPieceState
                    } else {
                        Task { @MainActor in
                            self.moving = true
                            self.disablePieceHoverEffect()
                            if entityPieceState.index != latestPieceState.index {
                                if !entityPieceState.picked {
                                    await self.raisePiece(pieceEntity, entityPieceState.index, animation)
                                }
                                let duration: TimeInterval = animation ? 1 : 0
                                pieceEntity.move(to: .init(translation: latestPieceState.index.position),
                                                 relativeTo: self.rootEntity,
                                                 duration: duration)
                                try? await Task.sleep(for: .seconds(duration))
                                await self.lowerPiece(pieceEntity, latestPieceState.index, animation)
                            } else {
                                if entityPieceState.picked != latestPieceState.picked {
                                    var translation = entityPieceState.index.position
                                    translation.y = latestPieceState.picked ? FixedValue.pickedOffset : 0
                                    let duration: TimeInterval = animation ? 0.6 : 0
                                    let pieceBodyEntity = pieceEntity.findEntity(named: "body")!
                                    pieceBodyEntity.move(to: .init(translation: translation),
                                                         relativeTo: self.rootEntity,
                                                         duration: duration)
                                    try? await Task.sleep(for: .seconds(duration))
                                }
                            }
                            pieceEntity.components[PieceStateComponent.self] = latestPieceState
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
        if animation { self.soundEffect.execute() }
    }
    private func disablePieceHoverEffect() {
        self.rootEntity
            .children
            .filter { $0.components.has(PieceStateComponent.self) }
            .forEach { $0.findEntity(named: "body")!.components.remove(HoverEffectComponent.self) }
    }
    private func activatePieceHoverEffect() {
        self.rootEntity
            .children
            .filter { $0.components.has(PieceStateComponent.self) }
            .forEach { $0.findEntity(named: "body")!.components.set(HoverEffectComponent()) }
    }
}

//MARK: ==== SharePlay ====
extension 🥽AppModel {
    func sendMessage() {
        Task {
            try? await self.messenger?.send(self.gameState)
        }
    }
    private func receive(_ newGameState: GameState) {
        self.gameState = newGameState
        self.applyLatestSituationToEntities()
    }
}
