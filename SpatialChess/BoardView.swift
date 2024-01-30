import SwiftUI

struct BoardView: View {
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<8, id: \.self) { column in
                VStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { row in
                        if (column + row) % 2 == 0 {
                            Rectangle().fill(.background)
                        } else {
                            Color.clear
                        }
                    }
                }
            }
        }
        .overlay {
            HStack(spacing: 0) {
                ForEach(1...8, id: \.self) {
                    Spacer()
                    if $0 < 8 { Color.primary.frame(width: 0.5) }
                }
            }
            VStack(spacing: 0) {
                ForEach(1...8, id: \.self) {
                    Spacer()
                    if $0 < 8 { Color.primary.frame(height: 0.5) }
                }
            }
        }
        .mask(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(lineWidth: 2)
        }
        .frame(width: self.physicalMetrics.convert(FixedValue.boardSize, from: .meters),
               height: self.physicalMetrics.convert(FixedValue.boardSize, from: .meters))
        .padding(48)
        .glassBackgroundEffect()
        .rotation3DEffect(.degrees(90), axis: .x)
    }
}
