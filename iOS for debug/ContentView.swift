import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        VStack {
            MainMenu()
            ChessView()
            ToolbarView()
        }
        .scaleEffect(self.model.activityState.viewScale)
        .offset(y: ActivityState().viewHeight - self.model.activityState.viewHeight)
        .animation(.default, value: self.model.activityState.viewHeight)
        .overlay { if !self.model.movingPieces.isEmpty { ProgressView() } }
        .task { SharePlayProvider.registerGroupActivity() }
        .environmentObject(self.model)
    }
}
