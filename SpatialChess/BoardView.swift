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
                .stroke(Color(white: 0.75), lineWidth: 3)
        }
        .frame(width: self.physicalMetrics.convert(FixedValue.boardSize, from: .meters),
               height: self.physicalMetrics.convert(FixedValue.boardSize, from: .meters))
        .padding(48)
        .overlay(alignment: .bottomTrailing) {
            Button {
                self.model.reset()
            } label: {
                Image(systemName: "arrow.counterclockwise")
            }
            .padding()
        }
        .glassBackgroundEffect()
        .rotation3DEffect(.degrees(90), axis: .x)
    }
}
