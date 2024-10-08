import simd

enum Action: Codable, Equatable {
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
    case drag(Piece,
              sourceIndex: Index,
              dragTranslation: SIMD3<Float>,
              isDragStarted: Bool)
    case dropAndBack(Piece,
                     sourceIndex: Index,
                     dragTranslation: SIMD3<Float>)
    case dropAndMove(Piece,
                     sourceIndex: Index,
                     dragTranslation: SIMD3<Float>,
                     newIndex: Index)
    case dropAndMoveAndCapture(Piece,
                               sourceIndex: Index,
                               dragTranslation: SIMD3<Float>,
                               capturedPiece: Piece,
                               capturedPieceIndex: Index)
    case undo
    case reset
}

extension Action {
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
            case .drag(let piece, _, _, _):
                [piece]
            case .dropAndBack(let piece, _, _):
                [piece]
            case .dropAndMove(let piece, _, _, _):
                [piece]
            case .dropAndMoveAndCapture(let piece, _, _, let capturedPiece, _):
                [piece, capturedPiece]
            case .undo, .reset:
                []
        }
    }
    var isPicking: Bool {
        switch self {
            case .tapPieceAndPick(_, _), .tapPieceAndChangePickingPiece(_, _, _, _):
                true
            default:
                false
        }
    }
    var draggedPiecePosition: SIMD3<Float> {
        .init(x: self.draggedPieceBodyPosition.x,
              y: 0,
              z: self.draggedPieceBodyPosition.z)
    }
    var draggedPieceBodyYOffset: Float {
        self.draggedPieceBodyPosition.y
    }
}

private extension Action {
    private var draggedPieceBodyPosition: SIMD3<Float> {
        switch self {
            case .drag(_, let index, let dragTranslation, _),
                    .dropAndBack(_, let index, let dragTranslation),
                    .dropAndMove(_, let index, let dragTranslation, _),
                    .dropAndMoveAndCapture(_, let index, let dragTranslation, _, _):
                var value = dragTranslation
                if dragTranslation.y < 0 {
                    value.y = 0
                }
                return index.position + value
            default:
                return .zero
        }
    }
}
