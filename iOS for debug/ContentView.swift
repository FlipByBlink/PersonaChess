import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        VStack {
            MainMenu()
            ChessView_iOS()
            MenuViewDuring3DMode()
        }
        .task { SharePlayProvider.registerGroupActivity() }
    }
}
