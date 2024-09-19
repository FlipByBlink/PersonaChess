import RealityKit

enum Action: Equatable, Codable {
    case tapPiece(Piece.ID),
         tapSquare(Index),
         drag(Piece.ID, translation: SIMD3<Float>),
         drop(Index),
         undo,
         reset
}
