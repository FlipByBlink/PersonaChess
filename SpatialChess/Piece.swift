struct Piece {
    var chessmen: Chessmen
    var side: Side
    init(_ chessmen: Chessmen, _ side: Side) {
        self.chessmen = chessmen
        self.side = side
    }
}

extension Piece {
    var assetName: String {
        "\(self.chessmen)" 
        +
        (self.side == .black ? "B" : "W")
    }
}
