import SwiftUI

struct SpatialSuggestionDialog: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        Label {
            Text("""
                You are currently not in Spatial mode.
                Please switch to Spatial mode from Control Center or FaceTime window.
                """)
        } icon: {
            Image(systemName: "exclamationmark.triangle.fill")
                .imageScale(.large)
                .padding(8)
        }
        .fixedSize()
        .symbolRenderingMode(.multicolor)
        .padding()
        .padding(.horizontal, 8)
        .glassBackgroundEffect()
        .opacity(self.isPresented ? 1.0 : 0)
        .animation(.default, value: self.isPresented)
        .offset(y: -1800)
        .offset(z: -1220 - Size.Point.board(self.physicalMetrics))
    }
}

private extension SpatialSuggestionDialog {
    var isPresented: Bool {
        self.model.spatialSharePlaying == false
    }
}
