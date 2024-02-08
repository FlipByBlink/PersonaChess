import RealityKit

struct PieceLooksSystem: System {
    private static let query = EntityQuery(where: .has(PieceStateComponent.self))
    
    init(scene: Scene) {}
    
    func update(context: SceneUpdateContext) {
        let pieceEntities = context.scene.performQuery(Self.query).map { $0 }
        
        guard !pieceEntities.isEmpty else { return }
        
        for pieceEntity in pieceEntities {
            self.handleOpacity(pieceEntity)
        }
    }
}

private extension PieceLooksSystem {
    private func handleOpacity(_ pieceEntity: Entity) {
        if pieceEntity.components[PieceStateComponent.self]!.removed {
            if pieceEntity.components[OpacityComponent.self]!.opacity > 0 {
                pieceEntity.components[OpacityComponent.self]!.opacity -= 0.04
            }
        } else {
            if pieceEntity.components[OpacityComponent.self]!.opacity < 1 {
                pieceEntity.components[OpacityComponent.self]!.opacity += 0.04
            }
        }
    }
}
