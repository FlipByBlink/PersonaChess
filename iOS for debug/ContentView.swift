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
        .animation(.default, value: self.model.activityState.viewHeight)
        .task { SoundFeedback.setCategory() }
        .task {
            for await session in AppGroupActivity.sessions() {
                self.model.configureGroupSession(session)
            }
        }
        .environmentObject(self.model)
        .overlay { if self.model.moving { ProgressView() } }
    }
}
