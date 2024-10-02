import RealityKit

struct Piece {
    let chessmen: Chessmen
    let side: Side
    var state: Self.State
}

extension Piece: Codable, Equatable {
    enum State: Codable, Equatable {
        case active(index: Index,
                    promotion: Bool = false)
        case removed
    }
    
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
    
    var index: Index? {
        if case .active(let value, _) = self.state {
            value
        } else {
            nil
        }
    }
    
    var isActive: Bool {
        switch self.state {
            case .active(_, _): true
            case .removed: false
        }
    }
    
    var isRemoved: Bool {
        switch self.state {
            case .active(_, _): false
            case .removed: true
        }
    }
    
    var isPromoted: Bool {
        switch self.state {
            case .active(_, let value): value
            case .removed:false
        }
    }
    
    mutating func setNew(index: Index) {
        let satisfiedPromotion: Bool = {
            if self.isPromoted {
                return true
            }
            if self.chessmen.role == .pawn {
                switch self.side {
                    case .white: return index.row == 0
                    case .black: return index.row == 7
                }
            } else {
                return false
            }
        }()
        self.state = .active(index: index, promotion: satisfiedPromotion)
    }
    
    var assetName: String {
        "\(self.chessmen.role)"
        +
        (self.side == .black ? "B" : "W")
    }
    
    func dragTargetingIndex(_ dragTranslation: SIMD3<Float>) -> Index {
        guard let index else { return .init(0, 0) }
        var closestIndex = Index(0, 0)
        let bodyPosition = index.position + dragTranslation
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
