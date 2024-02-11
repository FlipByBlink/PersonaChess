import Foundation

struct Chess {
    var latest: [Piece] = []
    var log: [[Piece]] = []
}

extension Chess: Codable, Equatable {
    mutating func setPreset() {
        self.latest = Self.preset
    }
    var isPreset: Bool {
        self.latest == Self.preset
    }
    mutating func movePiece(_ id: Piece.ID, to index: Index) {
        self.unpick(id)
        self.latest[self.arrayIndex(id)].index = index
    }
    mutating func removePiece(_ id: Piece.ID) {
        self.latest[self.arrayIndex(id)].removed = true
    }
    mutating func removeAllPieces() {
        for index in self.latest.indices {
            self.latest[index].removed = true
        }
    }
    var allPiecesRemoved: Bool { self.latest.allSatisfy { $0.removed } }
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
    mutating func clearLog() {
        self.log.removeAll()
    }
}

private extension Chess {
    private func arrayIndex(_ id: Piece.ID) -> Int {
        self.latest.firstIndex { $0.id == id }!
    }
    private static var preset: [Piece] {
        var value: [Piece] = []
        [Chessmen.rook0, .knight0, .bishop0, .queen, .king, .bishop1, .knight1, .rook1].enumerated().forEach {
            value.append(.init(index: .init(0, $0.offset),
                               chessmen: $0.element,
                               side: .black))
        }
        [Chessmen.pawn0, .pawn1, .pawn2, .pawn3, .pawn4, .pawn5, .pawn6, .pawn7].enumerated().forEach {
            value.append(.init(index: .init(1, $0),
                               chessmen: $1,
                               side: .black))
        }
        [Chessmen.pawn0, .pawn1, .pawn2, .pawn3, .pawn4, .pawn5, .pawn6, .pawn7].enumerated().forEach {
            value.append(.init(index: .init(6, $0),
                               chessmen: $1,
                               side: .white))
        }
        [Chessmen.rook0, .knight0, .bishop0, .queen, .king, .bishop1, .knight1, .rook1].enumerated().forEach {
            value.append(.init(index: .init(7, $0.offset),
                               chessmen: $0.element,
                               side: .white))
        }
        return value
    }
}
