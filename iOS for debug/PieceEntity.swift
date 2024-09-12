import RealityKit

enum PieceEntity {
    static func load(_ piece: Piece) -> Entity {
        let value = Entity()
        value.components.set([piece])
        let bodyEntity = Entity()
        bodyEntity.name = "body"
        value.addChild(bodyEntity)
        return value
    }
}
