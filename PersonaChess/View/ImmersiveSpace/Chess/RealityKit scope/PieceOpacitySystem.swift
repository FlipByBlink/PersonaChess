import RealityKit

struct PieceOpacitySystem: System {
    private static let query = EntityQuery(where: .has(Piece.self))
    
    init(scene: Scene) {}
    
    func update(context: SceneUpdateContext) {
        let pieceEntities = context.scene.performQuery(Self.query).map { $0 }
        
        guard !pieceEntities.isEmpty else { return }
        
        let draggingPieceEntity = pieceEntities.first { $0.components[Piece.self]!.dragging }
        
        for pieceEntity in pieceEntities {
            if pieceEntity.components[Piece.self]!.removed {
                Self.adjustOpacity(pieceEntity, amount: -0.04, limit: 0)
            } else {
                if let draggingPieceEntity {
                    Self.adjustTargetingPieceOpacity(pieceEntity, draggingPieceEntity)
                } else {
                    Self.adjustOpacity(pieceEntity, amount: 0.04, limit: 1)
                }
            }
        }
    }
}

private extension PieceOpacitySystem {
    private static func adjustOpacity(_ pieceEntity: Entity, amount: Double, limit: Float) {
        if amount > 0 {
            if pieceEntity.components[OpacityComponent.self]!.opacity < limit {
                pieceEntity.components[OpacityComponent.self]!.opacity += 0.04
            }
        } else {
            if pieceEntity.components[OpacityComponent.self]!.opacity > limit {
                pieceEntity.components[OpacityComponent.self]!.opacity -= 0.04
            }
        }
    }
    private static func adjustTargetingPieceOpacity(_ pieceEntity: Entity, _ draggingPieceEntity: Entity) {
        guard pieceEntity != draggingPieceEntity else { return }
        let distance = distance(.zero, pieceEntity.position(relativeTo: draggingPieceEntity))
        switch distance {
            case ..<(Size.Meter.square/2):
                Self.adjustOpacity(pieceEntity, amount: -0.005, limit: 0.4)
            default:
                Self.adjustOpacity(pieceEntity, amount: 0.005, limit: 1)
        }
    }
}
