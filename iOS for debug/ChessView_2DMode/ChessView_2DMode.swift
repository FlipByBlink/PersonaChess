import SwiftUI

struct ChessView_2DMode: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<8, id: \.self) { column in
                VStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { row in
                        SquareView_2DMode(row: row,
                                          column: column)
                    }
                }
            }
        }
        .overlay {
            ZStack {
                ForEach(self.model.sharedState.pieces.all) {
                    if let index = self.model.sharedState.pieces.indices[$0] {
                        PieceView_2DMode(piece: $0,
                                         index: index)
                    }
                }
            }
//            .animation(.default, value: self.model.sharedState.pieces.all)
        }
        .highPriorityGesture(self.dragGesture)
        .overlay {
            if self.model.showProgressView { ProgressView() }
            if self.model.isAnimating { ProgressView() }
        }
    }
}

private extension ChessView_2DMode {
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged {
                guard let piece = self.model.sharedState.pieces.piece_2DMode($0.startLocation) else {
                    return
                }
                let dragTranslation = SIMD3<Float>(
                    x: Size.Meter.convertFromPoint_2DMode($0.translation.width),
                    y: 0,
                    z: Size.Meter.convertFromPoint_2DMode($0.translation.height)
                )
                self.model.handle(.drag(piece,
                                        translation: dragTranslation))
            }
            .onEnded {
                guard let piece = self.model.sharedState.pieces.piece_2DMode($0.startLocation) else {
                    return
                }
                let dragTranslation = SIMD3<Float>(
                    x: Size.Meter.convertFromPoint_2DMode($0.translation.width),
                    y: 0,
                    z: Size.Meter.convertFromPoint_2DMode($0.translation.height)
                )
                self.model.handle(.drop(piece,
                                        dragTranslation: dragTranslation))
            }
    }
}
