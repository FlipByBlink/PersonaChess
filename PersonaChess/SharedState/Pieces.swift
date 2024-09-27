import RealityKit

struct Pieces {
    private var value: [Piece]
    private(set) var currentAction: Action? = nil
    private(set) var log: [[Piece]]
}

extension Pieces: Codable, Equatable {
    subscript(_ id: Piece.ID) -> Piece {
        get { self.value[self.value.firstIndex { $0.id == id }!] }
        set { self.value[self.value.firstIndex { $0.id == id }!] = newValue }
    }
    subscript(_ index: Index) -> Piece? {
        self.value[self.value.firstIndex { $0.index == index }!]
    }
    static var empty: Self { .init(value: Self.preset, log: []) }
    mutating func setPreset() { self.value = Self.preset }
    var isPreset: Bool { self.value == Self.preset }
    mutating func apply(_ action: Action) {
        self.currentAction = action
        switch action {
            case .tapPieceAndPick(let id):
                self[id].picked = true
            case .tapSquareAndUnpick(let id):
                self[id].picked = false
            case .tapPieceAndChangePickingPiece(let pickedPieceID, let tappedPieceID):
                self[tappedPieceID].picked = true
                self[pickedPieceID].picked = false
            case .tapSquareAndMove(let id, let index):
                self.appendLog()
                self[id].picked = false
                self[id].index = index
                if self.satisfiedPromotion(id) {
                    self[id].promotion = true
                }
            case .tapPieceAndMoveAndCapture(let id, let index, let capturedPieceID):
                self.appendLog()
                self[id].picked = false
                self[id].index = index
                if self.satisfiedPromotion(id) {
                    self[id].promotion = true
                }
                self[capturedPieceID].removed = true
            case .drag(let pieceID, let dragTranslation):
                var resultTranslation: SIMD3<Float> = dragTranslation
                if dragTranslation.y > 0 {
                    resultTranslation.y = dragTranslation.y
                }
                self[pieceID].dragTranslation = resultTranslation
            case .dropAndBack(let pieceID, let from):
                self[pieceID].dragTranslation = nil
            case .dropAndMove(let pieceID, let from, let to):
                self.appendLog()
                self[pieceID].dragTranslation = nil
                self[pieceID].index = self[pieceID].dragTargetingIndex()
                if self.satisfiedPromotion(pieceID) {
                    self[pieceID].promotion = true
                }
            case .dropAndMoveAndCapture(let pieceID, let from, let to, let capturedPiece):
                self.appendLog()
                self[pieceID].dragTranslation = nil
                self[pieceID].index = self[pieceID].dragTargetingIndex()
                if self.satisfiedPromotion(pieceID) {
                    self[pieceID].promotion = true
                }
                self[capturedPiece]
            case .undo:
                guard let previousValue = self.log.popLast() else {
                    assertionFailure(); return
                }
                self.value = previousValue
            case .reset:
                self.appendLog()
                self.setPreset()
        }
    }
    var activeOnly: [Piece] {
        self.value.filter { !$0.removed }
    }
    static func shouldPlaySound(_ draggedPieceBodyEntity: Entity) -> Bool {
        draggedPieceBodyEntity.parent!.components[Piece.self]!.dragging == false
    }
    mutating func clearAllLog() {
        self.log.removeAll()
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
    static func shouldLog(_ droppedPieceBodyEntity: Entity) -> Bool {
        let droppedPiece = droppedPieceBodyEntity.parent!.components[Piece.self]!
        let targetingIndex = droppedPiece.dragTargetingIndex()
        return droppedPiece.index != targetingIndex
    }
    mutating func appendLog() {
        self.log.append(
            self.value.reduce(into: []) {
                var piece = $1
                piece.picked = false
                piece.dragTranslation = nil
                $0.append(piece)
            }
        )
    }
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
