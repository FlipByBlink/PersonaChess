import Foundation

struct GameState: Codable {
    var previousSituation: [PieceStateComponent] = []
    var latestAction: Action? = nil
    var latestSituation: [PieceStateComponent] = Self.preset
}

private extension GameState {
    private static var preset: [PieceStateComponent] {
        var value: [PieceStateComponent] = []
        [Chessmen.rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook].enumerated().forEach {
            value.append(.init(index: .init(0, $0.offset),
                               chessmen: $0.element,
                               side: .black))
        }
        (0..<8).forEach {
            value.append(.init(index: .init(1, $0),
                               chessmen: .pawn,
                               side: .black))
        }
        (0..<8).forEach {
            value.append(.init(index: .init(6, $0),
                               chessmen: .pawn,
                               side: .white))
        }
        [Chessmen.rook, .knight, .bishop, .king, .queen, .bishop, .knight, .rook].enumerated().forEach {
            value.append(.init(index: .init(7, $0.offset),
                               chessmen: $0.element,
                               side: .white))
        }
        return value
    }
}
