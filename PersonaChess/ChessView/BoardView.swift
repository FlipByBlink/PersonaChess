import SwiftUI

struct BoardView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<8, id: \.self) { column in
                VStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { row in
                        SquareView(row, column)
                    }
                }
            }
        }
        .mask(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(white: self.model.floorMode ? 1 : 0.75),
                        lineWidth: 3)
        }
        .overlay { FloorModeDividers() }
        .padding(Size.Point.boardInnerPadding(self.physicalMetrics))
        .frame(width: Size.Point.board(self.physicalMetrics),
               height: Size.Point.board(self.physicalMetrics))
        .glassBackgroundEffect(displayMode: self.model.floorMode ? .never : .always)
        .overlay {
            if self.model.isSharePlayStateNotSet {
                ProgressView()
                    .offset(z: 10)
            }
        }
        .animation(.default, value: self.model.isSharePlayStateNotSet)
        .rotation3DEffect(.degrees(90), axis: .x)
    }
}
