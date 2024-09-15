import RealityKit

enum PieceEntity {
    static func load(_ piece: Piece) -> Entity {
        let value = Entity()
        value.position = piece.index.position
        value.components.set([piece,
                              OpacityComponent()])
        
        let bodyEntity = try! Entity.load(named: piece.assetName)
        bodyEntity.name = "body"
        bodyEntity.components.set([
            HoverEffectComponent(),
            InputTargetComponent(),
            CollisionComponent(shapes: [{
                var value: ShapeResource = .generateBox(size: bodyEntity.visualBounds(relativeTo: nil).extents)
                value = value.offsetBy(translation: [0, value.bounds.extents.y / 2, 0])
                return value
            }()])
        ])
        
        let promotionMarkEntity = Entity()
        promotionMarkEntity.name = "promotionMark"
        promotionMarkEntity.isEnabled = false
        let material = SimpleMaterial(color: .init(white: piece.side == .white ? 0.9 : 0.15,
                                                   alpha: 1),
                                      isMetallic: false)
        promotionMarkEntity.components.set(ModelComponent(mesh: .generateSphere(radius: 0.005),
                                                          materials: [material]))
        promotionMarkEntity.position.y = 0.06
        bodyEntity.addChild(promotionMarkEntity)
        value.addChild(bodyEntity)
        
        let shadowEntity = ModelEntity(
            mesh: .generateCylinder(height: 0.001,
                                    radius: bodyEntity.visualBounds(relativeTo: nil).extents.x * 0.48),
            materials: [UnlitMaterial(color: .black, applyPostProcessToneMap: true)]
        )
        shadowEntity.components.set(OpacityComponent(opacity: 0.3))
        value.addChild(shadowEntity)
        
        return value
    }
}
