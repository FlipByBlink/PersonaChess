enum BoardPosition {
    case center,
         up,
         down,
         right,
         left
}

extension BoardPosition: Codable {}
