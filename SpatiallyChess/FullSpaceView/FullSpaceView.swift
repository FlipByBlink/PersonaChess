import SwiftUI

struct FullSpaceView: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        VStack(spacing: 12) {
            ChessView()
            ToolbarsView(targetScene: .fullSpace)
        }
        .scaleEffect(self.model.activityState.viewScale, anchor: .bottom)
        .offset(z: self.model.isSpatial ? 0 : -1000)
        .offset(y: -self.model.activityState.viewHeight)
        .animation(.default, value: self.model.activityState.viewScale)
        .animation(.default, value: self.model.activityState.viewHeight)
        .task { SoundFeedback.setCategory() }
    }
}
