import RealityKit

enum Action: Equatable {
    case tapPiece(Entity),
         tapSquare(Index),
         back,
         reset
}
