import SwiftUI

extension Pieces {
    func offset_2DMode(_ piece: Piece) -> CGSize? {
        guard let index = self.indices[piece] else {
            return nil
        }
        if case .drag(let draggedPiece, _, _, _) = self.currentAction,
           draggedPiece == piece,
           let draggedPiecePosition = self.currentAction?.draggedPiecePosition {
            return CGSize(width: Size.Point.convertFromMeter_2DMode(draggedPiecePosition.x),
                          height: Size.Point.convertFromMeter_2DMode(draggedPiecePosition.z))
        } else {
            return CGSize(width: Size.Point.convertFromMeter_2DMode(index.position.x),
                          height: Size.Point.convertFromMeter_2DMode(index.position.z))
        }
    }
    func piece_2DMode(_ location: CGPoint) -> Piece? {
        let row = Int(location.y / Size.Point.squareSize_2DMode)
        let column = Int(location.x / Size.Point.squareSize_2DMode)
        return self.piece(Index(row, column))
    }
}
