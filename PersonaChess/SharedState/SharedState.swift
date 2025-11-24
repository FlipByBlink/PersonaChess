struct SharedState {
    var pieces: Pieces = .preset
    var logs: [Pieces] = []
    var boardAngle: Double = 0
    var viewScale: Double = Self.defaultViewScale
    var boardPosition: BoardPosition = .center
    
    var messageIndex: Int?
}

extension SharedState: Codable, Equatable {
    mutating func logIfNecessary(_ action: Action) {
        switch action {
            case .tapSquareAndMove(_, _, _),
                    .tapSquareAndMoveAndCapture(_, _, _, _),
                    .dropAndMove(_, _),
                    .dropAndMoveAndCapture(_, _, _),
                    .remove(_),
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
}

extension SharedState {
    static var defaultViewScale = 4.0
}
