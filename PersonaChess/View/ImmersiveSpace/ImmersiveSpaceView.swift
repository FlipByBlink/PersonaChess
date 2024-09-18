import SwiftUI

struct ImmersiveSpaceView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        ChessView()
            .scaleEffect(self.model.sharedState.viewScale, anchor: .bottom)
            .offset(z: self.zOffset)
            .offset(y: -self.model.sharedState.viewHeight)
            .animation(.default, value: self.model.sharedState.viewScale)
            .animation(.default, value: self.model.sharedState.viewHeight)
            .overlay { ToolbarViewOnHand() }
            .overlay { SpatialSuggestionDialog() }
            .overlay { RecordingRoom() }
            .onAppear { self.model.isFullSpaceShown = true }
            .onDisappear { self.model.isFullSpaceShown = false }
    }
}

private extension ImmersiveSpaceView {
    private var zOffset: CGFloat {
        if self.model.spatialSharePlaying == true {
            self.physicalMetrics.convert(Size.Meter.spatialZOffset,
                                         from: .meters)
        } else {
            -Size.Point.nonSpatialZOffset
        }
    }
}
