import SwiftUI

struct CenterWindowView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    var body: some View {
        NavigationStack {
            ZStack {
                if self.model.isFullSpaceShown {
                    ChessMenuView()
                } else {
                    if self.model.groupSession == nil {
                        GuideMenuView()
                    } else {
                        PlaceholderView()
                    }
                }
            }
            .navigationTitle("PersonaChess")
            .toolbar { OpenChessButton() }
        }
        .animation(.default, value: self.model.isFullSpaceShown)
        .animation(.default, value: self.model.groupSession == nil)
        .frame(width: 450, height: 400)
        .task { SharePlayProvider.registerGroupActivity() }
        .onChange(of: self.scenePhase) { _, newValue in
            if newValue == .background {
                if self.model.isFullSpaceShown {
                    Task { await self.dismissImmersiveSpace() }
                }
            }
        }
    }
}
