import Foundation

struct Chess {
    var latest: [Piece] = []
    var log: [[Piece]] = []
}

extension Chess: Codable, Equatable {
    mutating func movePiece(_ id: Piece.ID, to index: Index) {
        self.unpick(id)
        self.latest[self.arrayIndex(id)].index = index
    }
    mutating func removePiece(_ id: Piece.ID) {
        self.latest[self.arrayIndex(id)].removed = true
    }
    mutating func pick(_ id: Piece.ID) {
        self.latest[self.arrayIndex(id)].picked = true
    }
    mutating func unpick(_ id: Piece.ID) {
        self.latest[self.arrayIndex(id)].picked = false
    }
    mutating func appendLog() {
        self.log.append(
            self.latest.reduce(into: []) {
                var piece = $1
                piece.picked = false
                $0.append(piece)
            }
        )
    }
}

private extension Chess {
    private func arrayIndex(_ id: Piece.ID) -> Int {
        self.latest.firstIndex { $0.id == id }!
    }
}