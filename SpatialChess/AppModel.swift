import SwiftUI
import RealityKit

class AppModel: ObservableObject {
    @Published var gameState: GameState = .init()
    var rootEntity: Entity = .init()
}

extension AppModel {
    func pieceEntity(_ name: String) -> Entity? {
        self.rootEntity.findEntity(named: name)
    }
    func pickedPieceEntity() -> Entity? {
        self.rootEntity.children.first { $0.components[PieceStateComponent.self]?.picked == true }
    }
    func applyLatestAction(_ action: Action) {
        switch action {
            case .tapPiece(let id):
                if let entity = self.pieceEntity(id.uuidString) {
                    let state = entity.components[PieceStateComponent.self]!
                    entity.move(to: .init(translation: .init(x: 0,
                                                             y: state.picked ? -0.1 : 0.1,
                                                             z: 0)),
                                relativeTo: entity,
                                duration: 1)
                    entity.components[PieceStateComponent.self]!.picked.toggle()
                }
            case .tapSquare(let index):
                guard let entity = self.pickedPieceEntity() else {
                    return
                }
                entity.move(to: .init(translation: index.position),
                            relativeTo: self.rootEntity,
                            duration: 1)
                entity.components[PieceStateComponent.self]?.index = index
                entity.components[PieceStateComponent.self]?.picked.toggle()
        }
    }
    func updatePosition() {
        self.rootEntity.children.forEach {
            if let pieceState = $0.components[PieceStateComponent.self] {
                $0.position = pieceState.index.position
                if pieceState.picked { $0.position.y += 0.1 }
            }
        }
    }
}

extension AppModel { //MARK: ==== SharePlay ====
    func send(_ action: Action) {
        print(self.gameState)
    }
    func receive(_ gameState: GameState) {
        self.gameState = gameState
        self.updatePosition()
        if let action = gameState.latestAction {
            self.applyLatestAction(action)
        }
    }
}
