import SwiftUI

struct FullSpaceView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        ChessView()
            .scaleEffect(self.model.activityState.viewScale, anchor: .bottom)
            .offset(z: self.zOffset)
            .offset(y: -self.model.activityState.viewHeight)
            .animation(.default, value: self.model.activityState.viewScale)
            .animation(.default, value: self.model.activityState.viewHeight)
            .overlay { ToolbarViewOnHand() }
            .overlay { SpatialSuggestionDialog() }
            .overlay { RecordingRoom() }
            .onAppear { self.model.isFullSpaceShown = true }
            .onDisappear { self.model.isFullSpaceShown = false }
    }
}

private extension FullSpaceView {
    private var zOffset: CGFloat {
        if self.model.spatialSharePlaying == true {
            self.physicalMetrics.convert(Size.Meter.spatialZOffset,
                                         from: .meters)
        } else {
            -Size.Point.nonSpatialZOffset
        }
    }
}
