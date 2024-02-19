import SwiftUI

struct ContentView: View {
    @StateObject private var model: AppModel = .init()
    var body: some View {
        VStack(spacing: 2) {
            SharePlayMenu()
            ChessView()
            ToolbarView()
        }
        .scaleEffect(self.model.activityState.viewScale)
        .offset(y: ActivityState().viewHeight - self.model.activityState.viewHeight)
        .animation(.default, value: self.model.activityState.viewHeight)
        .task { SoundFeedback.setCategory() }
        .environmentObject(self.model)
        .overlay { if !self.model.movingPieces.isEmpty { ProgressView() } }
    }
}
