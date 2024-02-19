import SwiftUI

struct FullSpaceView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    var body: some View {
        VStack(spacing: 8) {
            ChessView()
            ToolbarsView()
        }
        .scaleEffect(self.model.activityState.viewScale, anchor: .bottom)
        .offset(z: self.model.isSpatial ? 0 : -1000)
        .offset(y: -self.model.activityState.viewHeight)
        .animation(.default, value: self.model.activityState.viewScale)
        .animation(.default, value: self.model.activityState.viewHeight)
        .task { SoundFeedback.setCategory() }
        .onChange(of: self.model.activityState.preferredScene) { _, newValue in
            if newValue == .window {
                Task {
                    self.openWindow(id: "window")
                    await self.dismissImmersiveSpace()
                }
            }
        }
    }
}
