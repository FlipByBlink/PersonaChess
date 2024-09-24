import RealityKit

struct Pieces {
    private var current: [Piece]
    private(set) var log: [[Piece]]
}

extension Pieces: Codable, Equatable {
    subscript(_ id: Piece.ID) -> Piece {
        get { self.current[self.current.firstIndex { $0.id == id }!] }
        set { self.current[self.current.firstIndex { $0.id == id }!] = newValue }
    }
    static var empty: Self { .init(current: Self.preset, log: []) }
    mutating func setPreset() {
        self.current = Self.preset
    }
    var isPreset: Bool {
        self.current == Self.preset
    }
    mutating func movePiece(_ id: Piece.ID, to index: Index) {
        self.unpick(id)
        self[id].index = index
        if self.satisfiedPromotion(id) {
            self[id].promotion = true
        }
    }
    mutating func removePiece(_ id: Piece.ID) {
        self[id].removed = true
    }
    mutating func pick(_ id: Piece.ID) {
        self[id].picked = true
    }
    mutating func unpick(_ id: Piece.ID) {
        self[id].picked = false
    }
    mutating func drag(_ bodyEntity: Entity, _ dragTranslation: SIMD3<Float>) {
        guard let pieceEntity = bodyEntity.parent,
              let piece = pieceEntity.components[Piece.self] else {
            fatalError()
        }
        var resultTranslation: SIMD3<Float> = dragTranslation
        if dragTranslation.y > 0 {
            resultTranslation.y = dragTranslation.y
        }
        self[piece.id].dragTranslation = resultTranslation
    }
    mutating func drop(_ bodyEntity: Entity) {
        let piece = bodyEntity.parent!.components[Piece.self]!
        let id = piece.id
        self[id].dragTranslation = nil
        let targetingIndex = piece.dragTargetingIndex()
        let targetingIndexPiece: Piece? = {
            self.current
                .filter { !$0.removed }
                .first { $0.index == targetingIndex }//TODO: リファクタリング
        }()
        if piece.side == targetingIndexPiece?.side { return }
        self[id].index = targetingIndex
        if self.satisfiedPromotion(id) {
            self[id].promotion = true
        }
        if let targetingIndexPiece,
           piece.side != targetingIndexPiece.side {
            self.removePiece(targetingIndexPiece.id)
        }
    }
    mutating func undo() {
        guard let previousChessValue = self.log.popLast() else {
            assertionFailure(); return
        }
        self.current = previousChessValue
    }
    static func shouldLog(_ droppedPieceBodyEntity: Entity) -> Bool {
        let droppedPiece = droppedPieceBodyEntity.parent!.components[Piece.self]!
        let targetingIndex = droppedPiece.dragTargetingIndex()
        return droppedPiece.index != targetingIndex
    }
    mutating func appendLog() {
        self.log.append(
            self.current.reduce(into: []) {
                var piece = $1
                piece.picked = false
                piece.dragTranslation = nil
                $0.append(piece)
            }
        )
    }
    mutating func clearAllLog() {
        self.log.removeAll()
    }
    var activeOnly: [Piece] {
        self.current.filter { !$0.removed }
    }
    static func shouldPlaySound(_ draggedPieceBodyEntity: Entity) -> Bool {
        draggedPieceBodyEntity.parent!.components[Piece.self]!.dragging == false
    }
    static var preset: [Piece] {
        var value: [Piece] = []
        [Chessmen.rook0, .knight0, .bishop0, .queen, .king, .bishop1, .knight1, .rook1]
            .enumerated()
            .forEach {
                value.append(.init(index: .init(0, $0.offset),
                                   chessmen: $0.element,
                                   side: .black))
            }
        [Chessmen.pawn0, .pawn1, .pawn2, .pawn3, .pawn4, .pawn5, .pawn6, .pawn7]
            .enumerated()
            .forEach {
                value.append(.init(index: .init(1, $0),
                                   chessmen: $1,
                                   side: .black))
            }
        [Chessmen.pawn0, .pawn1, .pawn2, .pawn3, .pawn4, .pawn5, .pawn6, .pawn7]
            .enumerated()
            .forEach {
                value.append(.init(index: .init(6, $0),
                                   chessmen: $1,
                                   side: .white))
            }
        [Chessmen.rook0, .knight0, .bishop0, .queen, .king, .bishop1, .knight1, .rook1]
            .enumerated()
            .forEach {
                value.append(.init(index: .init(7, $0.offset),
                                   chessmen: $0.element,
                                   side: .white))
            }
        return value
    }
}

private extension Pieces {
    private func satisfiedPromotion(_ id: Piece.ID) -> Bool {
        let piece = self[id]
        if piece.chessmen.role == .pawn {
            switch piece.side {
                case .white: return piece.index.row == 0
                case .black: return piece.index.row == 7
            }
        } else {
            return false
        }
    }
}
