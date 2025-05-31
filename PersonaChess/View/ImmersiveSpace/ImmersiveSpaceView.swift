import SwiftUI

struct ImmersiveSpaceView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        ChessView()
            .scaleEffect(self.model.sharedState.viewScale,
                         anchor: .bottomLeading)
            .offset(z: self.zOffset)
            .offset(x: Size.Point.board(self.physicalMetrics))
            .animation(.default, value: self.model.sharedState.viewScale)
            .overlay { ToolbarViewOnHand() }
            .overlay { SpatialSuggestionDialog() }
            .overlay { RecordingRoom() }
            .environment(\.sceneKind, .immersiveSpace)
            .handlesExternalEvents(preferring: [], allowing: [])
            .onAppear { self.model.isImmersiveSpaceShown = true }
            .onDisappear { self.model.isImmersiveSpaceShown = false }
    }
}

private extension ImmersiveSpaceView {
    private var zOffset: CGFloat {
        if self.model.spatialSharePlaying == true {
            0
        } else {
            -Size.Point.nonSpatialZOffset
        }
    }
}
