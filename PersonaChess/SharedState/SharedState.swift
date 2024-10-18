struct SharedState {
    var pieces: Pieces = .preset
    var logs: [Pieces] = []
    var viewHeight: Double = Size.Point.defaultHeight
    var viewScale: Double = 1.0
    var mode: Mode = .localOnly
}

extension SharedState: Codable, Equatable {
    mutating func clear() {
        self.pieces = .preset
        self.logs = []
        self.viewHeight = Size.Point.defaultHeight
        self.viewScale = 1.0
    }
    mutating func logIfNecessary(_ action: Action) {
        switch action {
            case .tapSquareAndMove(_, _, _),
                    .tapPieceAndMoveAndCapture(_, _, _, _),
                    .dropAndMove(_, _, _, _),
                    .dropAndMoveAndCapture(_, _, _, _, _),
                    .reset:
                self.logs.append(self.pieces.asLog)
            default:
                break
        }
    }
    mutating func undo() {
        guard let previousLog = self.logs.popLast() else {
            assertionFailure(); return
        }
        self.pieces = previousLog
    }
    mutating func clearAllLog() {
        self.logs.removeAll()
    }
}
