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
            .fixedSize()
            .padding()
            .padding(.horizontal, 8)
            .glassBackgroundEffect()
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
        .opacity(self.isPresented ? 1.0 : 0)
        .opacity(self.dismissedManually ? 0 : 1.0)
        .animation(.default, value: self.isPresented)
        .animation(.default, value: self.dismissedManually)
        .offset(y: -1400)
        .offset(z: -1200 - (Size.Point.board(self.physicalMetrics) / 2))
    }
}

private extension SpatialSuggestionDialog {
    var isPresented: Bool {
        self.model.spatialSharePlaying == false
    }
}
