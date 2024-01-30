import SwiftUI
import RealityKit

class AppModel: ObservableObject {
//    @Published var gameState: GameState = .preset
    var rootEntity: Entity = .init()
    var pieceEntities: [Entity] = []
}

extension AppModel {
    func pieceEntity(_ index: Index) -> Entity? {
        self.pieceEntities.first { index == $0.components[PieceStateComponent.self]?.index }
    }
    func pickedPieceEntity() -> Entity? {
        self.pieceEntities.first { $0.components[PieceStateComponent.self]?.picked == true }
    }
    func tapPiece(_ entity: Entity) {
        let state = entity.components[PieceStateComponent.self]!
        entity.move(to: .init(translation: .init(x: 0,
                                                 y: state.picked ? -0.1 : 0.1,
                                                 z: 0)),
                    relativeTo: entity,
                    duration: 1)
        entity.components[PieceStateComponent.self]!.picked.toggle()
    }
    func tapSquare(_ index: Index) {
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
