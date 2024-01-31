import RealityKit

struct ShadowSystem: System {
    private static let query = EntityQuery(where: .has(PieceStateComponent.self))
    
    init(scene: Scene) {}
    
    func update(context: SceneUpdateContext) {
        let pieceEntities = context.scene.performQuery(Self.query).map { $0 }
        
        guard !pieceEntities.isEmpty else { return }
        
        for pieceEntity in pieceEntities {
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
    }
}
