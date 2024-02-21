import SwiftUI

struct BoardView: View {
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
                .stroke(Color(white: 0.75), lineWidth: 3)
        }
        .padding(Size.Point.boardInnerPadding)
        .frame(width: Size.Point.board(self.physicalMetrics),
               height: Size.Point.board(self.physicalMetrics))
        .glassBackgroundEffect()
        .rotation3DEffect(.degrees(90), axis: .x)
    }
}
