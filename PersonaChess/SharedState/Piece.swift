import RealityKit

struct Piece {
    let chessmen: Chessmen
    let side: Side
    var index: Index
    var removed: Bool = false
    var promotion: Bool = false
}

extension Piece: Codable, Equatable {
    var id: Self.ID { .init(self.chessmen, self.side) }
    
    struct ID: Codable, Equatable, Component {
        var chessmen: Chessmen
        var side: Side
        init(_ chessmen: Chessmen, _ side: Side) {
            self.chessmen = chessmen
            self.side = side
        }
        static var allCases: [Piece.ID] {
            Chessmen.allCases.flatMap { chessmen in
                Side.allCases.map { side in
                        .init(chessmen, side)
                }
            }
        }
    }
    
    var assetName: String {
        "\(self.chessmen.role)"
        +
        (self.side == .black ? "B" : "W")
    }
    
    func dragTargetingIndex(_ dragTranslation: SIMD3<Float>) -> Index {
        var closestIndex = Index(0, 0)
        let bodyPosition = self.index.position + dragTranslation
        for column in 0..<8 {
            for row in 0..<8 {
                let index = Index(row, column)
                if distance(bodyPosition, closestIndex.position)
                    > distance(bodyPosition, index.position) {
                    closestIndex = index
                }
            }
        }
        return closestIndex
    }
}

//    var bodyYOffset: Float {
//        if self.bodyPosition.y > 0 {
//            self.bodyPosition.y
//        } else {
//            0
//        }
//    }
//    func position(_ dragTranslation: SIMD3<Float>? = nil) -> SIMD3<Float> {
//        let bodyPosition = self.bodyPosition(dragTranslation)
//        return .init(x: bodyPosition.x,
//                     y: 0,
//                     z: bodyPosition.z)
//    }
//    func bodyPosition(_ dragTranslation: SIMD3<Float>? = nil) -> SIMD3<Float> {
//        if let dragTranslation {
//            self.index.position + dragTranslation
//        } else {
//            self.index.position
//        }
//    }
//}
