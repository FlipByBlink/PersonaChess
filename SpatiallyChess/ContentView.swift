import SwiftUI

struct ContentView: View {
    @StateObject private var model: 🥽AppModel = .init()
    var body: some View {
        🌐RealityView()
            .task { 📢SoundEffect.setCategory() }
            .environmentObject(self.model)
    }
}
