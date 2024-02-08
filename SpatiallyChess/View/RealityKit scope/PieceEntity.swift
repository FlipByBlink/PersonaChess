import RealityKit

enum PieceEntity {
    static func load(_ pieceState: PieceStateComponent) -> Entity {
        let value = Entity()
        value.position = pieceState.index.position
        value.components.set([pieceState,
                              OpacityComponent()])
        
        let bodyEntity = try! Entity.load(named: pieceState.assetName)
        bodyEntity.name = "body"
        bodyEntity.components.set([
            HoverEffectComponent(),
            InputTargetComponent(),
            CollisionComponent(
                shapes: [.generateBox(size: bodyEntity.visualBounds(relativeTo: nil).extents)]
            )
        ])
        value.addChild(bodyEntity)
        
        let shadowEntity = ModelEntity(
            mesh: .generateCylinder(height: 0.0025,
                                    radius: bodyEntity.visualBounds(relativeTo: nil).extents.x * 0.48),
            materials: [SimpleMaterial(color: .black, isMetallic: false)]
        )
        shadowEntity.components.set(OpacityComponent(opacity: 0.4))
        shadowEntity.name = "shadow"
        value.addChild(shadowEntity)
        
        return value
    }
}
