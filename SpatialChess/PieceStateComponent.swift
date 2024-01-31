import Foundation
import RealityKit

struct PieceStateComponent: Component {
    var index: Index
    var chessmen: Chessmen
    var side: Side
    var picked: Bool = false
    var removed: Bool = false
    var id: Self.ID { .init(self.chessmen, self.side) }
}

extension PieceStateComponent: Codable, Equatable {
    var assetName: String {
        "\(self.chessmen.role)"
        +
        (self.side == .black ? "B" : "W")
    }
    struct ID: Codable, Equatable {
        var chessmen: Chessmen
        var side: Side
        init(_ chessmen: Chessmen, _ side: Side) {
            self.chessmen = chessmen
            self.side = side
        }
    }
}
