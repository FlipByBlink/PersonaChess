import Foundation

struct GameState: Codable, Equatable {
    var previousSituation: [PieceStateComponent] = []
    var latestAction: Action? = nil
}
