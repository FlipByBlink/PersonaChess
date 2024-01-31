import SwiftUI

struct ToolbarView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        HStack(spacing: 12) {
            Button {
            } label: {
                Label("Exit", systemImage: "escape")
                    .padding(8)
            }
            Button {
            } label: {
                Label("Back", systemImage: "arrow.uturn.backward")
                    .padding(8)
            }
            Button {
                self.model.reset()
            } label: {
                Label("Reset", systemImage: "arrow.counterclockwise")
                    .padding(8)
            }
        }
        .padding(12)
        .padding(.horizontal, 12)
        .buttonStyle(.plain)
        .font(.subheadline)
        .glassBackgroundEffect()
        .rotation3DEffect(.degrees(45), axis: .x)
        .offset(z: (self.physicalMetrics.convert(FixedValue.boardSize, from: .meters) / 2) + 80)
        .offset(y: 35)
    }
}
