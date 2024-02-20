import SwiftUI

struct FullScreenView: View {
    @EnvironmentObject var model: AppModel
    @Binding var presentFullScreen: Bool
    var body: some View {
        VStack {
            ChessView()
            ToolbarView(presentFullScreen: self.$presentFullScreen)
        }
        .scaleEffect(self.model.activityState.viewScale)
        .offset(y: ActivityState().viewHeight - self.model.activityState.viewHeight)
        .animation(.default, value: self.model.activityState.viewHeight)
        .overlay { if !self.model.movingPieces.isEmpty { ProgressView() } }
        .onChange(of: self.model.activityState.preferredScene) { _, newValue in
            if newValue == .window { self.presentFullScreen = false }
        }
        .environmentObject(self.model)
    }
}
