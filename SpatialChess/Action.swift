import Foundation

enum Action: Codable, Equatable {
    case tapPiece(PieceStateComponent.ID),
         tapSquare(Index)
}
