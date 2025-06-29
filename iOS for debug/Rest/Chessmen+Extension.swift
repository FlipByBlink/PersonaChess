extension Chessmen {
    func icon(isFilled: Bool) -> String {
        if isFilled {
            switch self {
                case .pawn0, .pawn1, .pawn2, .pawn3, .pawn4, .pawn5, .pawn6, .pawn7: "♙"
                case .rook0, .rook1: "♖"
                case .knight0, .knight1: "♘"
                case .bishop0, .bishop1: "♗"
                case .queen: "♕"
                case .king: "♔"
            }
        } else {
            switch self {
                case .pawn0, .pawn1, .pawn2, .pawn3, .pawn4, .pawn5, .pawn6, .pawn7: "♟\u{FE0E}"
                case .rook0, .rook1: "♜"
                case .knight0, .knight1: "♞"
                case .bishop0, .bishop1: "♝"
                case .queen: "♛"
                case .king: "♚"
            }
        }
    }
}
