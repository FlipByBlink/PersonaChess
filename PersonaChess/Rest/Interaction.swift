enum Interaction: Equatable {
    case tapPiece(Piece),
         tapSquare(Index),
         drag(DragState),
         drop(DragState)
}
