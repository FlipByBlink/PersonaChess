import RealityKit

struct PieceLooksSystem: System {
    private static let query = EntityQuery(where: .has(PieceStateComponent.self))
    
    init(scene: Scene) {}
    
    func update(context: SceneUpdateContext) {
        let pieceEntities = context.scene.performQuery(Self.query).map { $0 }
        
        guard !pieceEntities.isEmpty else { return }
        
        for pieceEntity in pieceEntities {
            self.handleShadow(pieceEntity)
            self.handleOpacity(pieceEntity)
        }
    }
}

private extension PieceLooksSystem {
    private func handleShadow(_ pieceEntity: Entity) {
        let shadowEntity: Entity
        if let value = pieceEntity.findEntity(named: "shadow") {
            shadowEntity = value
        } else {
            shadowEntity = ModelEntity(
                mesh: .generateCylinder(height: 0.002,
                                        radius: pieceEntity.visualBounds(relativeTo: nil).extents.x * 0.48),
                materials: [SimpleMaterial(color: .black, isMetallic: false)]
            )
            shadowEntity.components.set(OpacityComponent(opacity: 0.4))
            shadowEntity.name = "shadow"
            pieceEntity.addChild(shadowEntity)
        }
        shadowEntity.position.y = pieceEntity.parent!.position(relativeTo: pieceEntity).y
        shadowEntity.isEnabled = pieceEntity.components[PieceStateComponent.self]!.removed ? false : true
    }
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
