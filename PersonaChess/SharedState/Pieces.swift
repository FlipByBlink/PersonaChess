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
        self.value.first { $0.index == index }
    }
    static var empty: Self { .init(value: Self.preset, log: []) }
    mutating func setPreset() {
        self.value = Self.preset
        self.currentAction = nil
    }
    var isPreset: Bool {
        self.value == Self.preset
        &&
        self.currentAction == nil
    }
    var withAnimation: [Piece] {
        self.value.filter { self.hasAnimation($0.id) }
    }
    var withNoAnimation: [Piece] {
        self.value.filter { !self.hasAnimation($0.id) }
    }
    func hasAnimation(_ pieceID: Piece.ID) -> Bool {
        if let currentAction {
            currentAction.animatingPieceIDs.contains(pieceID)
        } else {
            false
        }
    }
    mutating func apply(_ action: Action) {
        self.currentAction = action
        switch action {
            case .tapSquareAndMove(let id, _, let newIndex):
                self.appendLog()
                self[id].setNew(index: newIndex)
            case .tapPieceAndMoveAndCapture(let pickedPieceID, _, let capturedPieceID, let targetIndex):
                self.appendLog()
                self[pickedPieceID].setNew(index: targetIndex)
                self[capturedPieceID].state = .removed
            case .dropAndMove(let pieceID, _, _, let newIndex):
                self.appendLog()
                self[pieceID].setNew(index: newIndex)
            case .dropAndMoveAndCapture(let pieceID, _, _, let capturedPieceID, let newIndex):
                self.appendLog()
                self[pieceID].setNew(index: newIndex)
                self[capturedPieceID].state = .removed
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
        self.value.filter { !$0.isRemoved }
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
    var capturedPieceInProgress: Piece? {
        switch self.currentAction {
            case .dropAndMoveAndCapture(_, _, _, let capturedPieceID, _),
                    .tapPieceAndMoveAndCapture(_, _, let capturedPieceID, _):
                self[capturedPieceID]
            default:
                nil
        }
    }
    var withoutCapturedPieceInProgress: [Piece] {
        if let capturedPieceInProgress {
            self.value.filter { $0 != capturedPieceInProgress }
        } else {
            self.value
        }
    }
    static var preset: [Piece] {
        var value: [Piece] = []
        [Chessmen.rook0, .knight0, .bishop0, .queen, .king, .bishop1, .knight1, .rook1]
            .enumerated()
            .forEach {
                value.append(.init(chessmen: $0.element,
                                   side: .black,
                                   state: .active(index: .init(0, $0.offset))))
            }
        [Chessmen.pawn0, .pawn1, .pawn2, .pawn3, .pawn4, .pawn5, .pawn6, .pawn7]
            .enumerated()
            .forEach {
                value.append(.init(chessmen: $1,
                                   side: .black,
                                   state: .active(index: .init(1, $0))))
            }
        [Chessmen.pawn0, .pawn1, .pawn2, .pawn3, .pawn4, .pawn5, .pawn6, .pawn7]
            .enumerated()
            .forEach {
                value.append(.init(chessmen: $1,
                                   side: .white,
                                   state: .active(index: .init(6, $0))))
            }
        [Chessmen.rook0, .knight0, .bishop0, .queen, .king, .bishop1, .knight1, .rook1]
            .enumerated()
            .forEach {
                value.append(.init(chessmen: $0.element,
                                   side: .white,
                                   state: .active(index: .init(7, $0.offset))))
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
}
