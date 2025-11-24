import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            ChessView_iOS()
                .overlay(alignment: .top) { HeaderMenu() }
            ChessView_2DMode()
            BottomMenuView()
        }
    }
}
