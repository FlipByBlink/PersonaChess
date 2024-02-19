import SwiftUI

struct ContentView: View {
    @StateObject private var model: AppModel = .init()
    @State private var presentFullScreen: Bool = false
    var body: some View {
        SharePlayMenu(presentFullScreen: self.$presentFullScreen)
            .fullScreenCover(isPresented: self.$presentFullScreen) {
                FullScreenView(presentFullScreen: self.$presentFullScreen)
            }
            .task { SoundFeedback.setCategory() }
            .onChange(of: self.model.activityState.preferredScene) { _, newValue in
                if newValue == .fullSpace { self.presentFullScreen = true }
            }
            .environmentObject(self.model)
    }
}
