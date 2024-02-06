import SwiftUI

struct ToolbarView: View {
    var body: some View {
        ZStack {
            ForEach(Self.Position.allCases, id: \.self) {
                Self.ContentView(position: $0)
            }
        }
    }
}

private extension ToolbarView {
    private enum Position: CaseIterable {
        case foreground, front, right, left
    }
    private struct ContentView: View {
        var position: ToolbarView.Position
        @EnvironmentObject var model: AppModel
        @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
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
                .foregroundStyle(.secondary)
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
                        Task { await self.dismissImmersiveSpace() }
                    } label: {
                        Label("Exit", systemImage: "escape")
                    }
                    Button {
                        self.model.back()
                    } label: {
                        Label("Back", systemImage: "arrow.uturn.backward")
                    }
                    .disabled(self.model.gameState.log.isEmpty)
                    Button {
                        self.model.reset()
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                    .disabled(self.model.gameState.latestSituation == FixedValue.preset)
                }
                .padding(12)
                .padding(.horizontal, 12)
                .font(.subheadline)
                .glassBackgroundEffect()
                .opacity(self.expanded ? 1 : 0)
            }
            .animation(.default, value: self.expanded)
            .rotation3DEffect(.degrees(45), axis: .x)
            .offset(z: (self.physicalMetrics.convert(FixedValue.boardSize, from: .meters) / 2) + 80)
            .rotation3DEffect(
                .degrees({
                    switch self.position {
                        case .foreground: 0
                        case .front: 180
                        case .right: 90
                        case .left: 270
                    }
                }()),
                axis: .y
            )
            .offset(y: 28)
        }
    }
}
