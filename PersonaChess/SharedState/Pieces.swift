import RealityKit

struct Pieces {
    private(set) var indices: [Piece: Index]
    private(set) var promotions: [Piece: Bool] = [:]
    private(set) var currentAction: Action? = nil
}

extension Pieces: Codable, Equatable {
    mutating func setPreset() { self = Self.preset }
    var isPreset: Bool { self == Self.preset }
    var list: [Piece] { self.indices.map(\.key) }
    func piece(_ index: Index) -> Piece? {
        self.indices
            .first { $0.value == index }?
            .key
    }
    mutating func apply(_ action: Action) {
        self.currentAction = action
        switch action {
            case .tapSquareAndMove(let piece, _, let newIndex),
                    .tapPieceAndMoveAndCapture(let piece, _, _, let newIndex),
                    .dropAndMove(let piece, _, _, let newIndex),
                    .dropAndMoveAndCapture(let piece, _, _, _, let newIndex):
                self.move(piece, newIndex)
            case .reset:
                self.setPreset()
            default:
                break
        }
    }
    func hasAnimation(_ piece: Piece) -> Bool {
        if let currentAction {
            currentAction.animatingPieces.contains(piece)
        } else {
            false
        }
    }
    var pickingPiece: Piece? {
        switch self.currentAction {
            case .tapPieceAndPick(let piece, _),
                    .tapPieceAndChangePickingPiece(_, _, let piece, _):
                piece
            default:
                nil
        }
    }
    var pickingPieceIndex: Index? {
        if let pickingPiece {
            self.indices[pickingPiece]
        } else {
            nil
        }
    }
    var capturedPieceInProgress: (piece: Piece, index: Index)? {
        switch self.currentAction {
            case .dropAndMoveAndCapture(_, _, _, let capturedPiece, let capturedPieceIndex),
                    .tapPieceAndMoveAndCapture(_, _, let capturedPiece, let capturedPieceIndex):
                (capturedPiece, capturedPieceIndex)
            default:
                nil
        }
    }
    var asLog: Self {
        var value = self
        value.currentAction = nil
        return value
    }
    static var preset: Self {
        var indices: [Piece: Index] = [:]
        [Chessmen.rook0, .knight0, .bishop0, .queen, .king, .bishop1, .knight1, .rook1]
            .enumerated()
            .forEach {
                indices[Piece(chessmen: $0.element, side: .black)] = Index(0, $0.offset)
            }
        [Chessmen.pawn0, .pawn1, .pawn2, .pawn3, .pawn4, .pawn5, .pawn6, .pawn7]
            .enumerated()
            .forEach {
                indices[Piece(chessmen: $1, side: .black)] = Index(1, $0)
            }
        [Chessmen.pawn0, .pawn1, .pawn2, .pawn3, .pawn4, .pawn5, .pawn6, .pawn7]
            .enumerated()
            .forEach {
                indices[Piece(chessmen: $1, side: .white)] = Index(6, $0)
            }
        [Chessmen.rook0, .knight0, .bishop0, .queen, .king, .bishop1, .knight1, .rook1]
            .enumerated()
            .forEach {
                indices[Piece(chessmen: $0.element, side: .white)] = Index(7, $0.offset)
            }
        return Self(indices: indices)
    }
}

private extension Pieces {
    private mutating func move(_ piece: Piece, _ newIndex: Index) {
        if self.shoudPromote(piece, newIndex) {
            self.promotions[piece] = true
        }
        if let capturedPiece = self.piece(newIndex) {
            self.indices[capturedPiece] = nil
        }
        self.indices[piece] = newIndex
    }
    private func shoudPromote(_ piece: Piece, _ newIndex: Index) -> Bool {
        if piece.chessmen.role == .pawn {
            switch piece.side {
                case .white: return newIndex.row == 0
                case .black: return newIndex.row == 7
            }
        } else {
            return false
        }
    }
}
