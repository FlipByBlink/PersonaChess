import RealityKit

struct Piece {
    let chessmen: Chessmen
    let side: Side
}

extension Piece: Codable, Equatable, Component, Hashable {
    static var allCases: [Self] {
        Chessmen.allCases.flatMap { chessmen in
            Side.allCases.map { side in
                Self(chessmen: chessmen,
                     side: side)
            }
        }
    }
    
    var assetName: String {
        "\(self.chessmen.role)"
        +
        (self.side == .black ? "B" : "W")
    }
}
