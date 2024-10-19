import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        VStack {
            MainMenu()
            ToolbarView()
            if !self.floorMode {
                ChessView_2DMode()
                    .offset(y: Size.Point.defaultHeight - self.model.sharedState.viewHeight)
                    .animation(.default, value: self.model.sharedState.viewHeight)
            }
            Spacer()
        }
        .task { SharePlayProvider.registerGroupActivity() }
        .overlay(alignment: .bottom) {
            if self.floorMode {
                ChessView_2DMode()
                    .border(.pink, width: 3)
            }
        }
        .environmentObject(self.model)
    }
}

private extension ContentView {
    private var floorMode: Bool {
        self.model.sharedState.viewHeight == 0
    }
}
