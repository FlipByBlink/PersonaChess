import SwiftUI

struct SpatialSuggestionDialog: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    @State private var dismissedManually: Bool = false
    var body: some View {
        HStack {
            Label {
                Text("""
                    You are currently not in Spatial mode.
                    Please switch to Spatial mode from Control Center or FaceTime window.
                    """)
            } icon: {
                Image(systemName: "exclamationmark.triangle.fill")
                    .imageScale(.large)
                    .padding(8)
                    .symbolRenderingMode(.multicolor)
            }
            .padding()
            .padding(.horizontal, 8)
            .glassBackgroundEffect()
            self.dismissButton()
        }
        .fixedSize()
        .opacity(self.isPresented ? 1.0 : 0)
        .opacity(self.dismissedManually ? 0 : 1.0)
        .animation(.default, value: self.isPresented)
        .animation(.default, value: self.dismissedManually)
        .offset(y: -1400)
        .offset(z: -Size.Point.nonSpatialZOffset - (Size.Point.board(self.physicalMetrics) / 2))
    }
}

private extension SpatialSuggestionDialog {
    private var isPresented: Bool {
        self.model.spatialSharePlaying == false
    }
    private func dismissButton() -> some View {
        Button {
            self.dismissedManually = true
        } label: {
            Image(systemName: "xmark")
                .padding(10)
        }
        .foregroundStyle(.secondary)
        .buttonStyle(.plain)
        .buttonBorderShape(.circle)
        .glassBackgroundEffect()
    }
}
