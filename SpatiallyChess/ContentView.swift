import SwiftUI

struct ContentView: View {
    @StateObject private var model: AppModel = .init()
    var body: some View {
        VStack(spacing: 2) {
            ChessView()
            ToolbarsView()
        }
        .scaleEffect(self.model.activityState.viewScale, anchor: .bottom)
        .offset(z: -1000)
        .offset(y: -self.model.activityState.viewHeight)
        .animation(.default, value: self.model.activityState.viewScale)
        .animation(.default, value: self.model.activityState.viewHeight)
        .task { SoundFeedback.setCategory() }
        .environmentObject(self.model)
    }
}
