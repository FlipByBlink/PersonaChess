import RealityKit

enum PieceEntity {
    static func load(_ piece: Piece) -> Entity {
#if os(visionOS)
        let value = Entity()
        value.position = piece.index.position
        value.components.set([piece,
                              OpacityComponent()])
        
        let bodyEntity = try! Entity.load(named: piece.assetName)
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
        value.addChild(shadowEntity)
        
        return value
#else
        let value = Entity()
        value.components.set([piece])
        
        let bodyEntity = Entity()
        bodyEntity.name = "body"
        value.addChild(bodyEntity)
        
        return value
#endif
    }
}
