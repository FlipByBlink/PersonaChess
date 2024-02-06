import SwiftUI
import RealityKit

struct ContentView: View {
    @StateObject var model: AppModel = .init()
    var body: some View {
        🌐RealityView()
            .task { 📢SoundEffect.setCategory() }
            .environmentObject(self.model)
    }
}
