import SwiftUI

struct FullSpaceView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) var openWindow
    var body: some View {
        VStack(spacing: 12) {
            ChessView()
            if !self.model.floorMode { ToolbarsView(targetScene: .fullSpace) }
        }
        .scaleEffect(self.model.activityState.viewScale, anchor: .bottom)
        .offset(z: self.model.spatialSharePlaying == true ? 0 : -Size.Point.nonSpatialZOffset)
        .offset(y: -self.model.activityState.viewHeight)
        .animation(.default, value: self.model.activityState.viewScale)
        .animation(.default, value: self.model.activityState.viewHeight)
        .overlay { ToolbarViewOnHand() }
        .overlay { SpatialSuggestionDialog() }
        .overlay { RecordingRoom() }
        .onChange(of: self.model.queueToOpenScene) { _, newValue in
            if newValue == .volume {
                Task {
                    self.openWindow(id: "volume")
                    await self.dismissImmersiveSpace()
                    self.model.clearQueueToOpenScene()
                }
            }
        }
        .onAppear { self.model.isFullSpaceShown = true }
        .onDisappear { self.model.isFullSpaceShown = false }
    }
}
