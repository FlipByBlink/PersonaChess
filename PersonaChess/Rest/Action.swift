import RealityKit

enum Action: Equatable {
    case tapPiece(Entity),
         tapSquare(Index),
         drag(Entity, translation: SIMD3<Float>),
         drop(Entity),
         undo,
         reset
}
