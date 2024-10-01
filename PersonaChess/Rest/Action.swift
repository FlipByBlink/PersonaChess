import simd

enum Action: Codable, Equatable {
    case tapPieceAndPick(Piece.ID, Index)
    case tapPieceAndChangePickingPiece(exPickedPieceID: Piece.ID,
                                       exPickedPieceIndex: Index,
                                       newPickedPieceID: Piece.ID,
                                       newPickedPieceIndex: Index)
    case tapPieceAndMoveAndCapture(pickedPieceID: Piece.ID,
                                   pickedPieceIndex: Index,
                                   capturedPieceID: Piece.ID,
                                   capturedPieceIndex: Index)
    case tapSquareAndUnpick(Piece.ID, Index)
    case tapSquareAndMove(Piece.ID,
                          exIndex: Index,
                          newIndex: Index)
    case drag(Piece.ID,
              sourceIndex: Index,
              dragTranslation: SIMD3<Float>)
    case dropAndBack(Piece.ID,
                     sourceIndex: Index,
                     dragTranslation: SIMD3<Float>)
    case dropAndMove(Piece.ID,
                     sourceIndex: Index,
                     dragTranslation: SIMD3<Float>,
                     newIndex: Index)
    case dropAndMoveAndCapture(Piece.ID,
                               sourceIndex: Index,
                               dragTranslation: SIMD3<Float>,
                               capturedPieceID: Piece.ID,
                               capturedPieceIndex: Index)
    case undo
    case reset
}

extension Action {
    var effectedPieceID: [Piece.ID] {
        switch self {
            case .tapPieceAndPick(let id, _):
                [id]
            case .tapPieceAndChangePickingPiece(let exPieceID, _, let newPieceID, _):
                [exPieceID, newPieceID]
            case .tapPieceAndMoveAndCapture(let pickedPieceID, _, let capturedPieceID, _):
                [pickedPieceID, capturedPieceID]
            case .tapSquareAndUnpick(let id, _):
                [id]
            case .tapSquareAndMove(let id, _, _):
                [id]
            case .drag(let id, _, _):
                [id]
            case .dropAndBack(let id, _, _):
                [id]
            case .dropAndMove(let id, _, _, _):
                [id]
            case .dropAndMoveAndCapture(let id, _, _, let capturedPieceID, _):
                [id, capturedPieceID]
            case .undo:
                []
            case .reset:
                Piece.ID.allCases
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
}
