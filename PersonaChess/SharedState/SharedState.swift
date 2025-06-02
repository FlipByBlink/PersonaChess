struct SharedState {
    var pieces: Pieces = .preset
    var logs: [Pieces] = []
    var boardAngle: Double = 0
    var viewScale: Double = Self.defaultViewScale
    var boardPosition: BoardPosition = .center
    var mode: Mode = .localOnly
}

extension SharedState: Codable, Equatable {
    mutating func clear() {
        self.pieces = .preset
        self.logs = []
        self.boardAngle = 0
        self.viewScale = Self.defaultViewScale
        self.boardPosition = .center
    }
    mutating func logIfNecessary(_ action: Action) {
        switch action {
            case .tapSquareAndMove(_, _, _),
                    .tapPieceAndMoveAndCapture(_, _, _, _),
                    .dropAndMove(_, _),
                    .dropAndMoveAndCapture(_, _, _),
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

extension SharedState {
    static var defaultViewScale = 4.0
}
