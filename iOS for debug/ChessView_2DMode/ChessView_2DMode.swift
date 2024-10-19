import SwiftUI

struct ChessView_2DMode: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<8, id: \.self) { column in
                VStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { row in
                        SquareView_2DMode(row, column)
                            .frame(width: Size.Point.squareSize_2DMode,
                                   height: Size.Point.squareSize_2DMode)
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
                        .frame(width: Size.Point.squareSize_2DMode,
                               height: Size.Point.squareSize_2DMode)
                    }
                }
            }
        }
        .mask(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color(white: 0.75), lineWidth: 3)
        }
        .gesture(
            DragGesture()
                .onChanged {
                    guard let piece = self.model.sharedState.pieces.piece_2DMode($0.startLocation) else {
                        return
                    }
                    let dragTranslation = SIMD3<Float>(x: Size.Meter.convertFromPoint_2DMode($0.translation.width),
                                                       y: 0,
                                                       z: Size.Meter.convertFromPoint_2DMode($0.translation.height))
                    self.model.handle(.drag(piece,
                                            translation: dragTranslation))
                }
                .onEnded {
                    guard let piece = self.model.sharedState.pieces.piece_2DMode($0.startLocation) else {
                        return
                    }
                    let dragTranslation = SIMD3<Float>(x: Size.Meter.convertFromPoint_2DMode($0.translation.width),
                                                       y: 0,
                                                       z: Size.Meter.convertFromPoint_2DMode($0.translation.height))
                    self.model.handle(.drop(piece,
                                            dragTranslation: dragTranslation))
                }
        )
        .overlay {
            if self.model.showProgressView { ProgressView() }
        }
        .scaleEffect(self.model.sharedState.viewScale)
        .animation(.default, value: self.model.sharedState.viewScale)
    }
}
