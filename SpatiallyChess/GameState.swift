import Foundation

struct GameState {
    var latestSituation: [PieceStateComponent] = []
    var log: [[PieceStateComponent]] = []
}

extension GameState: Codable, Equatable {
    mutating func movePiece(_ id: PieceStateComponent.ID, to index: Index) {
        self.unpick(id)
        self.latestSituation[self.arrayIndex(id)]
            .index = index
    }
    mutating func removePiece(_ id: PieceStateComponent.ID) {
        self.latestSituation[self.arrayIndex(id)]
            .removed = true
    }
    mutating func pick(_ id: PieceStateComponent.ID) {
        self.latestSituation[self.arrayIndex(id)]
            .picked = true
    }
    mutating func unpick(_ id: PieceStateComponent.ID) {
        self.latestSituation[self.arrayIndex(id)]
            .picked = false
    }
    mutating func logPreviousSituation() {
        self.log.append(
            self.latestSituation.reduce(into: []) {
                var pieceState = $1
                pieceState.picked = false
                $0.append(pieceState)
            }
        )
    }
}

private extension GameState {
    private func arrayIndex(_ id: PieceStateComponent.ID) -> Int {
        self.latestSituation.firstIndex { $0.id == id }!
    }
}