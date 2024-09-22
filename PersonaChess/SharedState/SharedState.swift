struct SharedState: Codable, Equatable {
    var pieces: Pieces = .empty
    var viewHeight: Double = Size.Point.defaultHeight
    var viewScale: Double = 1.0
    var mode: Mode = .localOnly
}

extension SharedState {
    mutating func clear() {
        self.pieces = .empty
        self.viewHeight = Size.Point.defaultHeight
        self.viewScale = 1.0
    }
}
