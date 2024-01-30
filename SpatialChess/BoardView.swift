import SwiftUI

struct BoardView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<8, id: \.self) { column in
                VStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { row in
                        Group {
                            if (column + row) % 2 == 0 {
                                Rectangle()
                                    .fill(.background)
                            } else {
                                Color.clear
                                    .glassBackgroundEffect(in: .rect)
                            }
                        }
                        .contentShape(.rect)
                        .hoverEffect()
                        .onTapGesture { self.model.tapSquare(.init(row, column)) }
                    }
                }
            }
        }
        .mask(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(lineWidth: 1.5)
        }
        .frame(width: self.physicalMetrics.convert(FixedValue.boardSize, from: .meters),
               height: self.physicalMetrics.convert(FixedValue.boardSize, from: .meters))
        .padding(48)
        .glassBackgroundEffect()
        .rotation3DEffect(.degrees(90), axis: .x)
    }
}
