import RealityKit

struct Piece {
    var index: Index
    let chessmen: Chessmen
    let side: Side
    var picked: Bool = false
    var removed: Bool = false
    var promotion: Bool = false
}

extension Piece: Component, Codable, Equatable {
    var id: Self.ID {
        .init(self.chessmen, self.side)
    }
    struct ID: Codable, Equatable {
        var chessmen: Chessmen
        var side: Side
        init(_ chessmen: Chessmen, _ side: Side) {
            self.chessmen = chessmen
            self.side = side
        }
    }
    var assetName: String {
        "\(self.chessmen.role)"
        +
        (self.side == .black ? "B" : "W")
    }
}
