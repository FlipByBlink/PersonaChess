import SwiftUI

struct ToolbarView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    @State private var expanded: Bool = false
    var body: some View {
        ZStack(alignment: .top) {
            Button {
                self.expanded = true
            } label: {
                Image(systemName: "ellipsis")
            }
            .opacity(self.expanded ? 0 : 1)
            HStack(spacing: 12) {
                Button {
                    self.expanded = false
                } label: {
                    Image(systemName: "arrow.down.right.and.arrow.up.left")
                        .padding(8)
                }
                .buttonBorderShape(.circle)
                .buttonStyle(.plain)
                Button {
                } label: {
                    Label("Exit", systemImage: "escape")
                }
                Button {
                } label: {
                    Label("Back", systemImage: "arrow.uturn.backward")
                }
                Button {
                    self.model.reset()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
            }
            .padding(12)
            .padding(.horizontal, 12)
            .font(.subheadline)
            .glassBackgroundEffect()
            .opacity(self.expanded ? 1 : 0)
        }
        .animation(.default, value: self.expanded)
        .rotation3DEffect(.degrees(45), axis: .x, anchor: .top)
        .offset(z: (self.physicalMetrics.convert(FixedValue.boardSize, from: .meters) / 2) + 80)
        .offset(y: 24)
    }
}
