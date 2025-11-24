import RealityKit
import SwiftUI

struct Pieces {
    private(set) var indices: [Piece: Index]
    private(set) var promotions: [Piece: Bool] = [:]
    private(set) var currentAction: Action? = nil
}

extension Pieces: Codable, Equatable {
    mutating func setPreset() { self = Self.preset }
    var isPreset: Bool { self == Self.preset }
    var all: [Piece] { self.indices.map(\.key) }
    func piece(_ index: Index) -> Piece? {
        self.indices
            .first { $0.value == index }?
            .key
    }
    mutating func apply(_ action: Action) {
        self.currentAction = action
        switch action {
            case .tapSquareAndMove(let piece, _, let newIndex),
                    .tapSquareAndMoveAndCapture(let piece, _, _, let newIndex):
                self.move(piece, newIndex)
            case .dropAndMove(let dragState, let newIndex),
                    .dropAndMoveAndCapture(let dragState, _, let newIndex):
                self.move(dragState.piece, newIndex)
            case .remove(let piece):
                self.remove(piece)
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
    var isPicking: Bool {
        switch self.currentAction {
            case .tapPieceAndPick(_, _),
                    .tapSquareAndChangePickingPiece(_, _, _, _):
                true
            default:
                false
        }
    }
    var pickingPiece: Piece? {
        switch self.currentAction {
            case .tapPieceAndPick(let piece, _),
                    .tapSquareAndChangePickingPiece(_, _, let piece, _):
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
    var draggingPiece: Piece? {
        if case .beginDrag(let state) = self.currentAction {
            state.piece
        } else {
            nil
        }
    }
    var asLog: Self {
        var value = self
        value.currentAction = nil
        return value
    }
}

private extension Pieces {
    private mutating func move(_ piece: Piece, _ newIndex: Index) {
        if self.shouldPromote(piece, newIndex) {
            self.promotions[piece] = true
        }
        if let capturedPiece = self.piece(newIndex) {
            self.remove(capturedPiece)
        }
        self.indices[piece] = newIndex
    }
    private mutating func remove(_ piece: Piece) {
        self.indices[piece] = nil
    }
    private func shouldPromote(_ piece: Piece, _ newIndex: Index) -> Bool {
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

extension Pieces {
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
