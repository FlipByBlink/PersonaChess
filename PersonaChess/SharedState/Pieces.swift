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
    var withEffect: [Piece] {
        self.value.filter { self.hasEffects($0.id) }
    }
    var withNoEffect: [Piece] {
        self.value.filter { !self.hasEffects($0.id) }
    }
    func hasEffects(_ pieceID: Piece.ID) -> Bool {
        if let currentAction {
            currentAction.effectedPieceID.contains(pieceID)
        } else {
            false
        }
    }
    mutating func apply(_ action: Action) {
        self.currentAction = action
        switch action {
            case .tapSquareAndMove(let id, _, let newIndex):
                self.appendLog()
                self[id].index = newIndex
                if self.satisfiedPromotion(id) {
                    self[id].promotion = true
                }
            case .tapPieceAndMoveAndCapture(let pickedPieceID, _, let capturedPieceID, let targetIndex):
                self.appendLog()
                self[pickedPieceID].index = targetIndex
                if self.satisfiedPromotion(pickedPieceID) {
                    self[pickedPieceID].promotion = true
                }
                self[capturedPieceID].removed = true
            case .dropAndMove(let pieceID, _, _, let newIndex):
                self.appendLog()
                self[pieceID].index = newIndex
                if self.satisfiedPromotion(pieceID) {
                    self[pieceID].promotion = true
                }
            case .dropAndMoveAndCapture(let pieceID, _, _, let capturedPieceID, let newIndex):
                self.appendLog()
                self[pieceID].index = newIndex
                if self.satisfiedPromotion(pieceID) {
                    self[pieceID].promotion = true
                }
                self[capturedPieceID].removed = true
            case .undo:
                guard let previousValue = self.log.popLast() else {
                    assertionFailure(); return
                }
                self.value = previousValue
            case .reset:
                self.appendLog()
                self.setPreset()
            case .tapPieceAndPick(_, _),
                    .tapSquareAndUnpick(_, _),
                    .tapPieceAndChangePickingPiece(_, _, _, _),
                    .drag(_, _, _),
                    .dropAndBack(_, _, _):
                break
        }
    }
    var activeOnly: [Piece] {
        self.value.filter { !$0.removed }
    }
    mutating func clearAllLog() {
        self.log.removeAll()
    }
    var pickingPiece: Piece? {
        switch self.currentAction {
            case .tapPieceAndPick(let id, _),
                    .tapPieceAndChangePickingPiece(_, _, let id, _):
                self[id]
            default:
                nil
        }
    }
    var draggedPiece: Piece? {
        switch self.currentAction {
            case .drag(let id, _, _):
                self[id]
            default:
                nil
        }
    }
    static var preset: [Piece] {
        var value: [Piece] = []
        [Chessmen.rook0, .knight0, .bishop0, .queen, .king, .bishop1, .knight1, .rook1]
            .enumerated()
            .forEach {
                value.append(.init(chessmen: $0.element,
                                   side: .black,
                                   index: .init(0, $0.offset)))
            }
        [Chessmen.pawn0, .pawn1, .pawn2, .pawn3, .pawn4, .pawn5, .pawn6, .pawn7]
            .enumerated()
            .forEach {
                value.append(.init(chessmen: $1,
                                   side: .black,
                                   index: .init(1, $0)))
            }
        [Chessmen.pawn0, .pawn1, .pawn2, .pawn3, .pawn4, .pawn5, .pawn6, .pawn7]
            .enumerated()
            .forEach {
                value.append(.init(chessmen: $1,
                                   side: .white,
                                   index: .init(6, $0)))
            }
        [Chessmen.rook0, .knight0, .bishop0, .queen, .king, .bishop1, .knight1, .rook1]
            .enumerated()
            .forEach {
                value.append(.init(chessmen: $0.element,
                                   side: .white,
                                   index: .init(7, $0.offset)))
            }
        return value
    }
}

private extension Pieces {
//    static func shouldLog(_ droppedPieceBodyEntity: Entity) -> Bool {
//        let droppedPiece = droppedPieceBodyEntity.parent!.components[Piece.self]!
//        let targetingIndex = droppedPiece.dragTargetingIndex()
//        return droppedPiece.index != targetingIndex
//    }
    mutating func appendLog() {
        self.log.append(self.value)
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
