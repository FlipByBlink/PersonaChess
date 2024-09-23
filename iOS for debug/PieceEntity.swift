import RealityKit

enum PieceEntity {
    static func load(_ piece: Piece) -> Entity {
        let value = Entity()
        value.position = piece.index.position
        value.components.set([piece,
                              OpacityComponent()])
        let bodyEntity = Entity()
        bodyEntity.name = "body"
        bodyEntity.components.set([HoverEffectComponent(),
                                   InputTargetComponent(),
                                   Self.collisionComponent(bodyEntity)])
        value.addChild(bodyEntity)
        value.addChild(Self.shadowEntity(bodyEntity))
        return value
    }
    static func addPromotionMarkEntity(_ pieceEntity: Entity, _ side: Side) {
        let promotionMarkEntity = Entity()
        promotionMarkEntity.name = "promotionMark"
        let material = SimpleMaterial(color: .init(white: side == .white ? 0.9 : 0.15,
                                                   alpha: 1),
                                      isMetallic: false)
        promotionMarkEntity.components.set(ModelComponent(mesh: .generateSphere(radius: 0.005),
                                                          materials: [material]))
        promotionMarkEntity.position.y = 0.06
        pieceEntity.findEntity(named: "body")!.addChild(promotionMarkEntity)
    }
    static func removePromotionMarkEntity(_ pieceEntity: Entity) {
        pieceEntity.findEntity(named: "promotionMark")?.removeFromParent()
    }
}

private extension PieceEntity {
    private static func shadowEntity(_ bodyEntity: Entity) -> Entity {
        let bodyEntityBounds = bodyEntity.visualBounds(relativeTo: bodyEntity)
        let value = ModelEntity(mesh: .generateCylinder(height: 0.001,
                                                        radius: bodyEntityBounds.extents.x * 0.48),
                                materials: [UnlitMaterial(color: .black,
                                                          applyPostProcessToneMap: true)])
        value.components.set(OpacityComponent(opacity: 0.3))
        return value
    }
    private static func collisionComponent(_ bodyEntity: Entity) -> some Component {
        CollisionComponent(
            shapes: [{
                let visualBounds = bodyEntity.visualBounds(relativeTo: bodyEntity)
                var value: ShapeResource = .generateBox(size: visualBounds.extents)
                value = value.offsetBy(translation: [0, visualBounds.extents.y / 2, 0])
                return value
            }()]
        )
    }
}
