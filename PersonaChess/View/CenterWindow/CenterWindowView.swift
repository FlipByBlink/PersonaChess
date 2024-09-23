import SwiftUI

struct CenterWindowView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    var body: some View {
        NavigationStack {
            ZStack {
                if self.model.isImmersiveSpaceShown {
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
            .toolbar { OpenButton() }
        }
        .animation(.default, value: self.model.isImmersiveSpaceShown)
        .animation(.default, value: self.model.groupSession == nil)
        .frame(width: 450, height: 400)
        .task { SharePlayProvider.registerGroupActivity() }
        .onChange(of: self.scenePhase) { _, newValue in
            if newValue == .background {
                if self.model.isImmersiveSpaceShown {
                    Task { await self.dismissImmersiveSpace() }
                }
            }
        }
    }
}
