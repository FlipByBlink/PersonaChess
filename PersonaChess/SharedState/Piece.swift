import RealityKit

struct Piece {
    var index: Index
    let chessmen: Chessmen
    let side: Side
    var picked: Bool = false
    var removed: Bool = false
    var promotion: Bool = false
    var id: Self.ID { .init(self.chessmen, self.side) }
}

extension Piece: Component, Codable, Equatable {
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
