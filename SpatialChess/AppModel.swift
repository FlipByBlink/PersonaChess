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
    func applyLatestAction(_ action: Action) {
        switch action {
            case .tapPiece(let id):
                let tappedPieceEntity = self.pieceEntity(id)!
                let tappedPieceState = tappedPieceEntity.components[PieceStateComponent.self]!
                if self.gameState.previousSituation.contains(where: { $0.picked }) {
                    let pickedPieceEntity = self.pickedPieceEntity()!
                    if tappedPieceEntity == pickedPieceEntity {
                        tappedPieceEntity.move(to: .init(translation: tappedPieceState.index.position),
                                               relativeTo: self.rootEntity,
                                               duration: 1)
                        tappedPieceEntity.components[PieceStateComponent.self]!.picked = false
                    } else {
                        let pickedPieceState = pickedPieceEntity.components[PieceStateComponent.self]!
                        if tappedPieceState.side == pickedPieceState.side {
                            pickedPieceEntity.move(to: .init(translation: pickedPieceState.index.position),
                                                   relativeTo: self.rootEntity,
                                                   duration: 1)
                            pickedPieceEntity.components[PieceStateComponent.self]!.picked = false
                            var translation = tappedPieceState.index.position
                            translation.y = FixedValue.pickedOffset
                            tappedPieceEntity.move(to: .init(translation: translation),
                                                   relativeTo: self.rootEntity,
                                                   duration: 1)
                            tappedPieceEntity.components[PieceStateComponent.self]!.picked = true
                        } else {
                            tappedPieceEntity.components[PieceStateComponent.self]!.removed = true
                            pickedPieceEntity.move(to: .init(translation: tappedPieceState.index.position),
                                                   relativeTo: self.rootEntity,
                                                   duration: 1)
                            pickedPieceEntity.components[PieceStateComponent.self]!.index = tappedPieceState.index
                            pickedPieceEntity.components[PieceStateComponent.self]!.picked = false
                        }
                    }
                } else {
                    var translation = tappedPieceState.index.position
                    translation.y = FixedValue.pickedOffset
                    tappedPieceEntity.move(to: .init(translation: translation),
                                           relativeTo: self.rootEntity,
                                           duration: 1)
                    tappedPieceEntity.components[PieceStateComponent.self]!.picked = true
                }
            case .tapSquare(let index):
                guard let pickedPieceEntity = self.pickedPieceEntity() else { return }
                pickedPieceEntity.move(to: .init(translation: index.position),
                                       relativeTo: self.rootEntity,
                                       duration: 1)
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
    func reset() {
        Task { @MainActor in
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
        self.rootEntity
            .children
            .filter { $0.components.has(PieceStateComponent.self) }
            .forEach {
                let pieceState = $0.components[PieceStateComponent.self]!
                //==== update Position ====
                $0.position = pieceState.index.position
                if pieceState.picked { $0.position.y = FixedValue.pickedOffset }
                //==== update PieceStateComponent ====
                if let newPieceState = self.gameState.previousSituation.first(where: { $0.id == pieceState.id }) {
                    $0.components[PieceStateComponent.self] = newPieceState
                }
                //====================================
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
