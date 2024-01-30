import Foundation
import RealityKit

struct PieceStateComponent: Component {
    var index: Index
    var chessmen: Chessmen
    var side: Side
    var picked: Bool = false
    var id: UUID = .init()
}

extension PieceStateComponent: Codable {
    var assetName: String {
        "\(self.chessmen)"
        +
        (self.side == .black ? "B" : "W")
    }
}
