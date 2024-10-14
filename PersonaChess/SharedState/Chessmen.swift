enum Chessmen {
    case pawn0, pawn1, pawn2, pawn3, pawn4, pawn5, pawn6, pawn7,
         rook0, rook1,
         knight0, knight1,
         bishop0, bishop1,
         queen,
         king
}

extension Chessmen: Codable, CaseIterable {
    var role: Self.Role {
        switch self {
            case .pawn0, .pawn1, .pawn2, .pawn3, .pawn4, .pawn5, .pawn6, .pawn7: .pawn
            case .rook0, .rook1: .rook
            case .knight0, .knight1: .knight
            case .bishop0, .bishop1: .bishop
            case .queen: .queen
            case .king: .king
        }
    }
    enum Role {
        case pawn,
             rook,
             knight,
             bishop,
             queen,
             king
    }
    func icon(isFilled: Bool) -> String {
        if isFilled {
            switch self {
                case .pawn0, .pawn1, .pawn2, .pawn3, .pawn4, .pawn5, .pawn6, .pawn7: "♟\u{FE0E}"
                case .rook0, .rook1: "♜"
                case .knight0, .knight1: "♞"
                case .bishop0, .bishop1: "♝"
                case .queen: "♛"
                case .king: "♚"
            }
        } else {
            switch self {
                case .pawn0, .pawn1, .pawn2, .pawn3, .pawn4, .pawn5, .pawn6, .pawn7: "♙"
                case .rook0, .rook1: "♖"
                case .knight0, .knight1: "♘"
                case .bishop0, .bishop1: "♗"
                case .queen: "♕"
                case .king: "♔"
            }
        }
    }
}
