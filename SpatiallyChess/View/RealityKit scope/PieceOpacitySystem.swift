import RealityKit

struct PieceOpacitySystem: System {
    private static let query = EntityQuery(where: .has(PieceStateComponent.self))
    
    init(scene: Scene) {}
    
    func update(context: SceneUpdateContext) {
        let pieceEntities = context.scene.performQuery(Self.query).map { $0 }
        
        guard !pieceEntities.isEmpty else { return }
        
        for pieceEntity in pieceEntities {
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
}
