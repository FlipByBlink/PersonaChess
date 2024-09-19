import RealityKit

struct Piece {
    var index: Index
    let chessmen: Chessmen
    let side: Side
    var picked: Bool = false
    var dragTranslation: SIMD3<Float>? = nil
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
    var dragging: Bool {
        self.dragTranslation != nil
    }
    var bodyYOffset: Float {
        if self.bodyPosition.y > 0 {
            self.bodyPosition.y
        } else {
            0
        }
    }
    var position: SIMD3<Float> {
        .init(x: self.bodyPosition.x,
              y: 0,
              z: self.bodyPosition.z)
    }
    func dragTargetingIndex() -> Index {
        var closestIndex = Index(0, 0)
        for column in 0..<8 {
            for row in 0..<8 {
                let index = Index(row, column)
                if distance(self.bodyPosition, closestIndex.position)
                    > distance(self.bodyPosition, index.position) {
                    closestIndex = index
                }
            }
        }
        return closestIndex
    }
}

private extension Piece {
    private var bodyPosition: SIMD3<Float> {
        if let dragTranslation {
            self.index.position + dragTranslation
        } else {
            self.index.position
        }
    }
}
