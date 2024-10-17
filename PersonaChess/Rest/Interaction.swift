enum Interaction: Equatable {
    case tapPiece(Piece),
         tapSquare(Index),
         drag(Piece, translation: SIMD3<Float>),
         drop(Piece, dragTranslation: SIMD3<Float>)
}
