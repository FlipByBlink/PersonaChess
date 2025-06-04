import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            ChessView_iOS()
                .overlay(alignment: .top) { MainMenu() }
            ChessView_2DMode()
            MenuViewDuring3DMode()
        }
        .task { SharePlayProvider.registerGroupActivity() }
    }
}
