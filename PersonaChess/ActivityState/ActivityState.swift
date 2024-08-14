struct ActivityState: Codable, Equatable {
    var chess: Chess = .empty
    var boardAngle: Double = 0
    var viewHeight: Double = Size.Point.defaultHeight
    var viewScale: Double = 1
    var expandedToolbar: [ToolbarPosition] = []
    var mode: Mode = .localOnly
}

extension ActivityState {
    mutating func clear() {
        self.chess = .empty
        self.boardAngle = 0
        self.viewHeight = Size.Point.defaultHeight
        self.viewScale = 1
        self.expandedToolbar = []
    }
}
