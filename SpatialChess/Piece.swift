import Foundation

enum Chessmen {
    case pawn,
         rook,
         knight,
         bishop,
         queen,
         king
}

struct Piece {
    var chessmen: Chessmen
    var side: Side
    init(_ chessmen: Chessmen, _ side: Side) {
        self.chessmen = chessmen
        self.side = side
    }
    var assetName: String {
        "\(self.chessmen)" 
        +
        (self.side == .black ? "B" : "W")
    }
}

struct GameState {
    var value: [Self.Position: Piece]
    
    struct Position: Hashable {
        var row: Int
        var column: Int
        init(_ row: Int, _ column: Int) {
            self.row = row
            self.column = column
        }
    }
    
    static var preset: [Self.Position: Piece] {
        var result: [Self.Position: Piece] = [:]
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
