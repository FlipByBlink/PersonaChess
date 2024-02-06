import SwiftUI
import RealityKit
import GroupActivities
import Combine

class AppModel: ObservableObject {
    @Published var gameState: GameState = .init()
    var rootEntity: Entity = .init()
    
    @Published private(set) var groupSession: GroupSession<👤GroupActivity>?
    private var messenger: GroupSessionMessenger?
    private var subscriptions = Set<AnyCancellable>()
    private var tasks = Set<Task<Void, Never>>()
    
    let soundEffect: 📢SoundEffect = .init()
}

extension AppModel {
    func setUpEntities() {
        self.rootEntity.position.y = 1.2
        self.rootEntity.position.z = -0.6
        self.gameState.latestSituation = FixedValue.preset
        self.gameState.latestSituation.forEach {
            self.rootEntity.addChild(self.loadPieceEntity($0))
        }
        
        for pieceState in self.gameState.latestSituation {
            self.rootEntity
                .children
                .first { $0.components[PieceStateComponent.self]?.id == pieceState.id }
                .map {
                    //==== update Position ====
                    $0.position = pieceState.index.position
                    $0.position.y = pieceState.picked ? FixedValue.pickedOffset : 0
                    //==== update PieceStateComponent ====
                    $0.components[PieceStateComponent.self]! = pieceState
                    //====================================
                }
        }
        
        self.applyLatestSituationToEntities(animation: false)
    }
    func applyLatestAction(_ action: Action) {
        switch action {
            case .tapPiece(let id):
                let tappedPieceEntity = self.pieceEntity(id)!
                let tappedPieceState = tappedPieceEntity.components[PieceStateComponent.self]!
                if self.gameState.latestSituation.contains(where: { $0.picked }) {
                    let pickedPieceEntity = self.pickedPieceEntity()! //FIXME: クラッシュするケースがある
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
        }
        self.applyLatestSituationToEntities()
        self.sendMessage()
    }
    func getLatestSituation() -> [PieceStateComponent] {
        self.rootEntity
            .children
            .filter { $0.components.has(PieceStateComponent.self) }
            .reduce(into: []) {
                $0.append($1.components[PieceStateComponent.self]!)
            }
    }
    func back() {
        if let oldGameState = self.gameState.log.popLast() {
            self.gameState.latestSituation = oldGameState
            self.applyLatestSituationToEntities(animation: false)
        }
    }
    func reset() {
        Task { @MainActor in
            self.gameState.logPreviousSituation()
            self.soundEffect.secondAction()
            self.gameState.latestSituation = FixedValue.preset
            self.applyLatestSituationToEntities()
            self.sendMessage()
        }
    }
}

private extension AppModel {
    private func loadPieceEntity(_ pieceState: PieceStateComponent) -> Entity {
        let value = try! Entity.load(named: pieceState.assetName)
        value.components.set([
            HoverEffectComponent(),
            InputTargetComponent(),
            OpacityComponent(),
            CollisionComponent(
                shapes: [.generateBox(size: value.visualBounds(relativeTo: nil).extents)]
            ),
            pieceState
        ])
        return value
    }
    private func pieceEntity(_ id: PieceStateComponent.ID) -> Entity? {
        self.rootEntity
            .children
            .filter { $0.components.has(PieceStateComponent.self) }
            .first { $0.components[PieceStateComponent.self]!.id == id }
    }
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
                    Task { @MainActor in
                        if entityPieceState.index != latestPieceState.index {
                            if !entityPieceState.picked {
                                self.raisePiece(pieceEntity, entityPieceState.index, animation)
                                if animation { try? await Task.sleep(for: .seconds(1)) }
                            }
                            var translation = latestPieceState.index.position
                            translation.y = FixedValue.pickedOffset
                            pieceEntity.move(to: .init(translation: translation),
                                             relativeTo: self.rootEntity,
                                             duration: animation ? 1 : 0)
                            if animation { try? await Task.sleep(for: .seconds(1)) }
                            self.lowerPiece(pieceEntity, latestPieceState.index, animation)
                            if animation {
                                try? await Task.sleep(for: .seconds(0.8))
                                self.soundEffect.execute()
                            }
                        } else {
                            if entityPieceState.picked != latestPieceState.picked {
                                var translation = entityPieceState.index.position
                                translation.y = latestPieceState.picked ? FixedValue.pickedOffset : 0
                                pieceEntity.move(to: .init(translation: translation),
                                                 relativeTo: self.rootEntity,
                                                 duration: animation ? 1 : 0)
                            }
                        }
                        pieceEntity.components[PieceStateComponent.self] = latestPieceState
                    }
                }
            }
    }
    private func raisePiece(_ entity: Entity, _ index: Index, _ animation: Bool) {
        var translation = index.position
        translation.y = FixedValue.pickedOffset
        entity.move(to: .init(translation: translation),
                    relativeTo: self.rootEntity,
                    duration: animation ? 1 : 0)
    }
    private func lowerPiece(_ entity: Entity, _ index: Index, _ animation: Bool) {
        entity.move(to: .init(translation: index.position),
                    relativeTo: self.rootEntity,
                    duration: animation ? 0.8 : 0)
    }
}

//MARK: ==== SharePlay ====
extension AppModel {
    func sendMessage() {
        Task {
            try? await self.messenger?.send(self.gameState)
        }
    }
    private func receive(_ gameState: GameState) {
        self.gameState = gameState
        self.applyLatestSituationToEntities()
    }
}
