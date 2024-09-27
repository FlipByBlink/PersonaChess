enum Action: Codable, Equatable {
    case tapPieceAndPick(Piece.ID),
         tapPieceAndChangePickingPiece(ex: Piece.ID, new: Piece.ID),
         tapPieceAndMoveAndCapture(Piece.ID, to: Index, capturedPiece: Piece.ID),
         tapSquareAndUnpick(Piece.ID),
         tapSquareAndMove(Piece.ID, to: Index),
         drag(Piece.ID, translation: SIMD3<Float>),
         dropAndBack(Piece.ID, from: SIMD3<Float>),
         dropAndMove(Piece.ID, from: SIMD3<Float>, to: Index),
         dropAndMoveAndCapture(Piece.ID, from: SIMD3<Float>, to: Index, capturedPiece: Piece.ID),
         undo,
         reset
}
