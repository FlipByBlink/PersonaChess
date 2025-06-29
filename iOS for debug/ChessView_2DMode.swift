import SwiftUI

struct ChessView_2DMode: View {
    @EnvironmentObject var model: AppModel
    
    @State private var dragState: DragState?
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<8) { column in
                VStack(spacing: 0) {
                    ForEach(0..<8) { row in
                        SquareView_2DMode(row: row,
                                          column: column)
                    }
                }
            }
        }
        .overlay {
            ForEach(Piece.allCases) {
                PieceView_2DMode(piece: $0,
                                 dragState: self.dragState)
            }
        }
        .animation(self.animation,
                   value: self.model.sharedState.pieces.currentAction)
        .highPriorityGesture(self.dragGesture)
    }
}

private extension ChessView_2DMode {
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged {
                guard let draggedPiece = self.model.sharedState.pieces.piece_2DMode($0.startLocation) else {
                    return
                }
                let dragTranslation = SIMD3<Float>(
                    x: Size.Meter.convertFromPoint_2DMode($0.translation.width),
                    y: 0,
                    z: Size.Meter.convertFromPoint_2DMode($0.translation.height)
                )
                let newDragState: DragState
                if let dragState {
                    newDragState = dragState.updating(dragTranslation)
                } else {
                    let sourceIndex = self.model.sharedState.pieces.indices[draggedPiece]!
                    newDragState = DragState(draggedPiece,
                                             sourceIndex,
                                             dragTranslation)
                }
                self.dragState = newDragState
                self.model.handle(.drag(newDragState))
            }
            .onEnded {
                guard let droppedPiece = self.model.sharedState.pieces.piece_2DMode($0.startLocation) else {
                    return
                }
                let dragTranslation = SIMD3<Float>(
                    x: Size.Meter.convertFromPoint_2DMode($0.translation.width),
                    y: 0,
                    z: Size.Meter.convertFromPoint_2DMode($0.translation.height)
                )
                let sourceIndex = self.model.sharedState.pieces.indices[droppedPiece]!
                self.model.handle(.drop(DragState(droppedPiece,
                                                  sourceIndex,
                                                  dragTranslation)))
                self.dragState = nil
            }
    }
    
    private var animation: Animation? {
        PieceAnimation.swiftUIAnimation_2DMode(self.model.sharedState.pieces.currentAction)
    }
}
