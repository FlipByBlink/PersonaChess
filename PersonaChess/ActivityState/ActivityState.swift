struct ActivityState: Codable, Equatable {
    var chess: Chess = .empty
    var viewHeight: Double = Size.Point.defaultHeight
    var viewScale: Double = 1
    var mode: Mode = .localOnly
}

extension ActivityState {
    mutating func clear() {
        self.chess = .empty
        self.viewHeight = Size.Point.defaultHeight
        self.viewScale = 1
    }
}
