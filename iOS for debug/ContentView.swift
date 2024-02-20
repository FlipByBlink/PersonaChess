import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: AppModel
    @State private var presentFullScreen: Bool = false
    var body: some View {
        SharePlayMenu(presentFullScreen: self.$presentFullScreen)
            .fullScreenCover(isPresented: self.$presentFullScreen) {
                FullScreenView(presentFullScreen: self.$presentFullScreen)
                    .environmentObject(self.model)
            }
            .task { SoundFeedback.setCategory() }
            .onChange(of: self.model.activityState.preferredScene) { _, newValue in
                if newValue == .fullSpace { self.presentFullScreen = true }
            }
            .environmentObject(self.model)
    }
}
