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
                                        radius: pieceEntity.visualBounds(relativeTo: nil).extents.x * (3/7)),
                materials: [SimpleMaterial(color: .black, isMetallic: false)]
            )
            shadowEntity.components.set(OpacityComponent(opacity: 0.25))
            shadowEntity.name = "shadow"
            pieceEntity.addChild(shadowEntity)
        }
        shadowEntity.position.y = pieceEntity.parent!.position(relativeTo: pieceEntity).y
    }
    private func handleOpacity(_ pieceEntity: Entity) {
        if pieceEntity.components[PieceStateComponent.self]!.removed {
            pieceEntity.components[OpacityComponent.self]!.opacity -= 0.02
            if pieceEntity.components[OpacityComponent.self]!.opacity <= 0 {
                pieceEntity.removeFromParent()
            }
        }
    }
}