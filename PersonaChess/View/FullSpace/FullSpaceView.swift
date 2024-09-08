import SwiftUI

struct FullSpaceView: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        ChessView()
            .scaleEffect(self.model.activityState.viewScale, anchor: .bottom)
            .offset(z: self.model.spatialSharePlaying == true ? 0 : -1200)
            .offset(y: -self.model.activityState.viewHeight)
            .animation(.default, value: self.model.activityState.viewScale)
            .animation(.default, value: self.model.activityState.viewHeight)
            .onAppear { self.model.isFullSpaceShown = true }
            .onDisappear { self.model.isFullSpaceShown = false }
    }
}
