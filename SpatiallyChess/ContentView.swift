import SwiftUI

struct ContentView: View {
    @StateObject private var model: AppModel = .init()
    var body: some View {
        VStack(spacing: 2) {
            ChessView()
            ToolbarsView()
        }
        .scaleEffect(self.model.scale, anchor: .bottom)
        .offset(z: -1000)
        .offset(y: -self.model.viewHeight)
        .animation(.default, value: self.model.scale)
        .animation(.default, value: self.model.viewHeight)
        .task { SoundEffect.setCategory() }
        .environmentObject(self.model)
    }
}
