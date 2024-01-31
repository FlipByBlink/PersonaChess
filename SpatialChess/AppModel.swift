import SwiftUI
import RealityKit
import GroupActivities
import Combine

class AppModel: ObservableObject {
    @Published var gameState: GameState = .init()
    @Published private(set) var log: [GameState] = []
    var rootEntity: Entity = .init()
    
    @Published private(set) var groupSession: GroupSession<👤GroupActivity>?
    private var messenger: GroupSessionMessenger?
    private var subscriptions = Set<AnyCancellable>()
    private var tasks = Set<Task<Void, Never>>()
}

extension AppModel {
    func setUpEntities() {
        self.rootEntity.position.y = 1.2
        self.rootEntity.position.z = -0.6
        self.gameState.previousSituation = FixedValue.preset
        self.gameState.previousSituation.forEach {
            self.rootEntity.addChild(self.loadPieceEntity($0))
        }
        self.reloadSituation()
    }
    func applyLatestAction(_ action: Action, animation: Bool = true) {
        switch action {
            case .tapPiece(let id):
                let tappedPieceEntity = self.pieceEntity(id)!
                let tappedPieceState = tappedPieceEntity.components[PieceStateComponent.self]!
                if self.gameState.previousSituation.contains(where: { $0.picked }) {
                    let pickedPieceEntity = self.pickedPieceEntity()!
                    if tappedPieceEntity == pickedPieceEntity {
                        tappedPieceEntity.move(to: .init(translation: tappedPieceState.index.position),
                                               relativeTo: self.rootEntity,
                                               duration: animation ? 1 : 0)
                        tappedPieceEntity.components[PieceStateComponent.self]!.picked = false
                    } else {
                        let pickedPieceState = pickedPieceEntity.components[PieceStateComponent.self]!
                        if tappedPieceState.side == pickedPieceState.side {
                            pickedPieceEntity.move(to: .init(translation: pickedPieceState.index.position),
                                                   relativeTo: self.rootEntity,
                                                   duration: animation ? 1 : 0)
                            pickedPieceEntity.components[PieceStateComponent.self]!.picked = false
                            var translation = tappedPieceState.index.position
                            translation.y = FixedValue.pickedOffset
                            tappedPieceEntity.move(to: .init(translation: translation),
                                                   relativeTo: self.rootEntity,
                                                   duration: animation ? 1 : 0)
                            tappedPieceEntity.components[PieceStateComponent.self]!.picked = true
                        } else {
                            tappedPieceEntity.components[PieceStateComponent.self]!.removed = true
                            pickedPieceEntity.move(to: .init(translation: tappedPieceState.index.position),
                                                   relativeTo: self.rootEntity,
                                                   duration: animation ? 1 : 0)
                            pickedPieceEntity.components[PieceStateComponent.self]!.index = tappedPieceState.index
                            pickedPieceEntity.components[PieceStateComponent.self]!.picked = false
                        }
                    }
                } else {
                    var translation = tappedPieceState.index.position
                    translation.y = FixedValue.pickedOffset
                    tappedPieceEntity.move(to: .init(translation: translation),
                                           relativeTo: self.rootEntity,
                                           duration: animation ? 1 : 0)
                    tappedPieceEntity.components[PieceStateComponent.self]!.picked = true
                }
            case .tapSquare(let index):
                guard let pickedPieceEntity = self.pickedPieceEntity() else { return }
                pickedPieceEntity.move(to: .init(translation: index.position),
                                       relativeTo: self.rootEntity,
                                       duration: animation ? 1 : 0)
                pickedPieceEntity.components[PieceStateComponent.self]?.index = index
                pickedPieceEntity.components[PieceStateComponent.self]?.picked = false
        }
    }
    func updateGameState(with action: Action) {
        self.gameState = .init(previousSituation: self.getLatestSituation(),
                               latestAction: action)
    }
    func getLatestSituation() -> [PieceStateComponent] {
        self.rootEntity
            .children
            .filter { $0.components.has(PieceStateComponent.self) }
            .reduce(into: []) {
                $0.append($1.components[PieceStateComponent.self]!)
            }
    }
    func addLog() {
        self.log.append(self.gameState)
    }
    func back() {
        if let oldGameState = self.log.popLast() {
            self.gameState = oldGameState
            self.reloadSituation()
            if let action = gameState.latestAction {
                self.applyLatestAction(action, animation: false)
            }
        }
    }
    func reset() {
        Task { @MainActor in
            self.addLog()
            self.rootEntity
                .children
                .filter { $0.components.has(PieceStateComponent.self) }
                .forEach { $0.components[PieceStateComponent.self]!.removed = true }
            try? await Task.sleep(for: .seconds(1))
            self.gameState = .init(previousSituation: FixedValue.preset, latestAction: nil)
            self.rootEntity
                .children
                .filter { $0.components.has(PieceStateComponent.self) }
                .forEach { pieceEntity in
                    pieceEntity.components[PieceStateComponent.self]!.index = {
                        FixedValue.preset
                            .first { $0.id == pieceEntity.components[PieceStateComponent.self]!.id }!
                            .index
                    }()
                    pieceEntity.components[PieceStateComponent.self]!.picked = false
                    pieceEntity.components[PieceStateComponent.self]!.removed = false
                }
            self.reloadSituation()
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
    private func reloadSituation() {
        for state in self.gameState.previousSituation {
            let entity = self.rootEntity.children.first { $0.components[PieceStateComponent.self]?.id == state.id }
            if let entity {
                //==== update Position ====
                entity.position = state.index.position
                entity.position.y = state.picked ? FixedValue.pickedOffset : 0
                //==== update PieceStateComponent ====
                entity.components[PieceStateComponent.self]! = state
                //====================================
            }
        }
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
        self.reloadSituation()
        if let action = gameState.latestAction {
            self.applyLatestAction(action)
        }
    }
}
