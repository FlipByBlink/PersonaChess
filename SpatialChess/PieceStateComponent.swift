import Foundation
import RealityKit

struct PieceStateComponent: Component {
    var index: Index
    var chessmen: Chessmen
    var side: Side
    var picked: Bool = false
    var removed: Bool = false
    var id: UUID = .init()
}

extension PieceStateComponent: Codable, Equatable {
    var assetName: String {
        "\(self.chessmen.role)"
        +
        (self.side == .black ? "B" : "W")
    }
}
