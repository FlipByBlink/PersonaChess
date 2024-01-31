enum Chessmen {
    case pawn0, pawn1, pawn2, pawn3, pawn4, pawn5, pawn6, pawn7,
         rook0, rook1,
         knight0, knight1,
         bishop0, bishop1,
         queen,
         king
}

extension Chessmen: Codable {
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
}
