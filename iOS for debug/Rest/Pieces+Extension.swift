import SwiftUI

extension Pieces {
    func offset_2DMode(_ piece: Piece, latestDragState: DragState?) -> CGSize? {
        guard let index = self.indices[piece] else {
            return nil
        }
        let basePosition = CGSize(width: Size.Point.convertFromMeter_2DMode(index.position.x),
                                  height: Size.Point.convertFromMeter_2DMode(index.position.z))
        guard case .beginDrag(let initialDragState) = self.currentAction else {
            return basePosition
        }
        if let latestDragState,
           latestDragState.piece == piece {
            return CGSize(
                width: Size.Point.convertFromMeter_2DMode(latestDragState.draggedPiecePosition.x),
                height: Size.Point.convertFromMeter_2DMode(latestDragState.draggedPiecePosition.z)
            )
        } else {
            if initialDragState.piece == piece {
                return CGSize(
                    width: Size.Point.convertFromMeter_2DMode(initialDragState.draggedPiecePosition.x),
                    height: Size.Point.convertFromMeter_2DMode(initialDragState.draggedPiecePosition.z)
                )
            } else {
               return basePosition
            }
        }
    }
    func piece_2DMode(_ location: CGPoint) -> Piece? {
        let row = Int(location.y / Size.Point.squareSize_2DMode)
        let column = Int(location.x / Size.Point.squareSize_2DMode)
        return self.piece(Index(row, column))
    }
}
