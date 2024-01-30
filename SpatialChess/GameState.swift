struct GameState {
    var value: [Position: Piece]
}

extension GameState {
    static var preset: [Position: Piece] {
        var result: [Position: Piece] = [:]
        [Chessmen.rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook].enumerated().forEach {
            result[.init(0, $0.offset)] = .init($0.element, .black)
        }
        (0..<8).forEach {
            result[.init(1, $0)] = .init(.pawn, .black)
        }
        (0..<8).forEach {
            result[.init(6, $0)] = .init(.pawn, .white)
        }
        [Chessmen.rook, .knight, .bishop, .king, .queen, .bishop, .knight, .rook].enumerated().forEach {
            result[.init(7, $0.offset)] = .init($0.element, .white)
        }
        return result
    }
}
