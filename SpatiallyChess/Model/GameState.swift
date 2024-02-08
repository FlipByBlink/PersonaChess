import Foundation

struct GameState {
    var latestSituation: [Piece] = []
    var log: [[Piece]] = []
}

extension GameState: Codable, Equatable {
    mutating func movePiece(_ id: Piece.ID, to index: Index) {
        self.unpick(id)
        self.latestSituation[self.arrayIndex(id)].index = index
    }
    mutating func removePiece(_ id: Piece.ID) {
        self.latestSituation[self.arrayIndex(id)].removed = true
    }
    mutating func pick(_ id: Piece.ID) {
        self.latestSituation[self.arrayIndex(id)].picked = true
    }
    mutating func unpick(_ id: Piece.ID) {
        self.latestSituation[self.arrayIndex(id)].picked = false
    }
    mutating func logPreviousSituation() {
        self.log.append(
            self.latestSituation.reduce(into: []) {
                var piece = $1
                piece.picked = false
                $0.append(piece)
            }
        )
    }
}

private extension GameState {
    private func arrayIndex(_ id: Piece.ID) -> Int {
        self.latestSituation.firstIndex { $0.id == id }!
    }
}
