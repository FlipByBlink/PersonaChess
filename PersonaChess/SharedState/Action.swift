import simd

enum Action {
    case tapPieceAndPick(Piece, Index)
    case tapPieceAndChangePickingPiece(exPickedPiece: Piece,
                                       exPickedPieceIndex: Index,
                                       newPickedPiece: Piece,
                                       newPickedPieceIndex: Index)
    case tapPieceAndMoveAndCapture(pickedPiece: Piece,
                                   pickedPieceIndex: Index,
                                   capturedPiece: Piece,
                                   capturedPieceIndex: Index)
    case tapSquareAndUnpick(Piece, Index)
    case tapSquareAndMove(Piece,
                          exIndex: Index,
                          newIndex: Index)
    case beginDrag(DragState)
    case dropAndBack(DragState)
    case dropAndMove(DragState,
                     newIndex: Index)
    case dropAndMoveAndCapture(DragState,
                               capturedPiece: Piece,
                               capturedPieceIndex: Index)
    case undo
    case reset
}

extension Action: Codable, Equatable {
    var animatingPieces: [Piece] {
        switch self {
            case .tapPieceAndPick(let piece, _):
                [piece]
            case .tapPieceAndChangePickingPiece(let exPiece, _, let newPiece, _):
                [exPiece, newPiece]
            case .tapPieceAndMoveAndCapture(let pickedPiece, _, let capturedPiece, _):
                [pickedPiece, capturedPiece]
            case .tapSquareAndUnpick(let piece, _):
                [piece]
            case .tapSquareAndMove(let piece, _, _):
                [piece]
            case .dropAndBack(let dragState):
                [dragState.piece]
            case .dropAndMove(let dragState, _):
                [dragState.piece]
            case .dropAndMoveAndCapture(let dragState, let capturedPiece, _):
                [dragState.piece, capturedPiece]
            case .beginDrag(_), .undo, .reset:
                []
        }
    }
    var hasAnimation: Bool {
        !self.animatingPieces.isEmpty
    }
}
