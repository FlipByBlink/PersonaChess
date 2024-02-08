import SwiftUI

struct ContentView: View {
    @StateObject private var model: 🥽AppModel = .init()
    var body: some View {
        ChessView()
            .task { 📢SoundEffect.setCategory() }
            .environmentObject(self.model)
    }
}
