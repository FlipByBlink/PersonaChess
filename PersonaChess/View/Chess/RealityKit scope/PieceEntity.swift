import RealityKit

enum PieceEntity {
    static func load(_ piece: Piece, _ index: Index) -> Entity {
        let value = Entity()
        value.position = index.position
        value.components.set([piece,
                              OpacityComponent()])
        let bodyEntity = try! Entity.load(named: piece.assetName)
        bodyEntity.name = "body"
        bodyEntity.components.set([HoverEffectComponent(),
                                   InputTargetComponent(),
                                   Self.collisionComponent(bodyEntity, piece)])
        value.addChild(bodyEntity)
        value.addChild(Self.shadowEntity(bodyEntity, piece))
        value.addChild(Self.soundEntity())
        return value
    }
    static func addPromotionMarkEntity(_ pieceEntity: Entity, _ side: Side) {
        guard pieceEntity.findEntity(named: "promotionMark") == nil else { return }
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
    private static func shadowEntity(_ bodyEntity: Entity, _ piece: Piece) -> Entity {
        let bodyEntityBounds = bodyEntity.visualBounds(relativeTo: bodyEntity)
        let height: Float = {
            0.0006
            +
            (Float(Piece.allCases.firstIndex(of: piece)!) * 0.00001)
            //to prevent flickering caused by overlapping shadows
        }()
        let value = ModelEntity(mesh: .generateCylinder(height: height,
                                                        radius: bodyEntityBounds.extents.x * 0.48),
                                materials: [UnlitMaterial(color: .black,
                                                          applyPostProcessToneMap: true)])
        value.components.set(OpacityComponent(opacity: 0.3))
        return value
    }
    private static func soundEntity() -> Entity {
        let value = Entity()
        value.name = "sound"
        value.components.set(Sound.Piece.audioLibraryComponent)
        return value
    }
    private static func collisionComponent(_ bodyEntity: Entity, _ piece: Piece) -> some Component {
        CollisionComponent(
            shapes: {
                let visualBounds = bodyEntity.visualBounds(relativeTo: bodyEntity)
                switch piece.chessmen.role {
                    case .king, .queen:
                        var bottom: ShapeResource = .generateCapsule(
                            height: visualBounds.extents.y/2,
                            radius: visualBounds.extents.x/2
                        )
                        var top: ShapeResource = .generateCapsule(
                            height: visualBounds.extents.y,
                            radius: visualBounds.extents.x/4
                        )
                        bottom = bottom.offsetBy(translation: [0, visualBounds.extents.y/4, 0])
                        top = top.offsetBy(translation: [0, visualBounds.extents.y/2, 0])
                        return [bottom, top]
                    default:
                        var shape: ShapeResource = .generateCapsule(height: visualBounds.extents.y,
                                                                    radius: visualBounds.extents.x/2)
                        shape = shape.offsetBy(translation: [0, visualBounds.extents.y / 2, 0])
                        return [shape]
                }
            }()
        )
    }
}
