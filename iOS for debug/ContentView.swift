import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        VStack {
            MainMenu()
            Spacer()
            ChessView_2DMode()
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.gray.tertiary)
                }
                .rotationEffect(.degrees(-self.model.sharedState.boardAngle))
            Spacer()
            MenuViewDuring3DMode()
        }
        .task { SharePlayProvider.registerGroupActivity() }
    }
}
