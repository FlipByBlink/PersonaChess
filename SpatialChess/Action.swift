import Foundation

enum Action: Codable, Equatable {
    case tapPiece(UUID),
         tapSquare(Index)
}
