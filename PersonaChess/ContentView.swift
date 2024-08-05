import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        VStack(spacing: 12) {
            ChessView()
            if !self.model.floorMode { ToolbarsView() }
        }
        .scaleEffect(self.model.activityState.viewScale, anchor: .bottom)
        .offset(z: self.model.spatialSharePlaying == true ? 0 : -1200)
        .offset(y: -self.model.activityState.viewHeight)
        .animation(.default, value: self.model.activityState.viewScale)
        .animation(.default, value: self.model.activityState.viewHeight)
        .overlay { ToolbarViewOnHand() }
        .overlay { MainMenu() }
        .overlay { RecordingRoom() }
    }
}
