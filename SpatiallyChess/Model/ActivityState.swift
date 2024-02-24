struct ActivityState: Codable, Equatable {
    var chess: Chess = .empty
    var boardAngle: Double = 0
    var viewHeight: Double = 1250
    var viewScale: Double = 1
    var expandedToolbar: [ToolbarPosition] = []
    var mode: Mode = .localOnly
}

extension ActivityState {
    mutating func clear() {
        self.chess = .empty
        self.boardAngle = 0
        self.viewHeight = 1250
        self.viewScale = 1
        self.expandedToolbar = []
    }
}
