import SwiftUI

struct FullSpaceView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) var openWindow
    var body: some View {
        VStack(spacing: 12) {
            ChessView()
            ToolbarsView(targetScene: .fullSpace)
        }
        .scaleEffect(self.model.activityState.viewScale, anchor: .bottom)
        .offset(z: self.spatialSharePlaying ? 0 : -1200)
        .offset(y: -self.model.activityState.viewHeight)
        .animation(.default, value: self.model.activityState.viewScale)
        .animation(.default, value: self.model.activityState.viewHeight)
        .task { SoundFeedback.setCategory() }
        .onChange(of: self.model.queueToOpenScene) { _, newValue in
            if newValue == .volume {
                Task {
                    self.openWindow(id: "volume")
                    await self.dismissImmersiveSpace()
                    self.model.clearQueueToOpenScene()
                }
            }
        }
    }
}

private extension FullSpaceView {
    private var spatialSharePlaying: Bool {
        self.model.isSpatial == true
    }
}
