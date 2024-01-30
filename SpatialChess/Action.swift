import Foundation

enum Action: Codable {
    case tapPiece(UUID),
         tapSquare(Index)
}
