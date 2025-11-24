import SwiftUI

struct SquareView_2DMode: View {
    @EnvironmentObject var model: AppModel
    
    var row: Int
    var column: Int
    
    var body: some View {
        Group {
            if (self.column + self.row) % 2 == 1 {
                Rectangle()
                    .fill(.tertiary)
            } else {
                Rectangle()
                    .opacity(0.001)
            }
        }
        .contentShape(.rect)
        .hoverEffect(isEnabled: self.model.sharedState.pieces.isPicking)
        .gesture(
            TapGesture().onEnded { _ in
                self.model.handle(.tapSquare(.init(self.row, self.column)))
            },
            isEnabled: self.model.sharedState.pieces.isPicking
        )
        .allowsHitTesting(self.model.sharedState.pieces.isPicking)
        .frame(width: Size.Point.squareSize_2DMode,
               height: Size.Point.squareSize_2DMode)
    }
}
