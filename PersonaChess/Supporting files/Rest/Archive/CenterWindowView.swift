import SwiftUI

struct CenterWindowView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    var body: some View {
        ZStack {
            Color.clear
            if self.model.isImmersiveSpaceShown {
                MenuViewDuring3DMode()
            } else {
                if self.model.isMenuSheetShown {
                    GuideMenuView()
                } else {
                    ChessView_2DMode()
                }
            }
        }
        .glassBackgroundEffect(in: .rect(cornerRadius: 20, style: .continuous))
        .frame(width: Size.Point.boardSize_2DMode,
               height: Size.Point.boardSize_2DMode)
        .ornament(attachmentAnchor: .scene(.bottom), contentAlignment: .top) {
            HStack(spacing: 24) {
                OpenAndDismiss3DSpaceButton()
                if !self.model.isImmersiveSpaceShown {
                    OpenMenuButton()
                }
            }
            .padding()
        }
        .animation(.default, value: self.model.isImmersiveSpaceShown)
        .animation(.default, value: self.model.isMenuSheetShown)
        .animation(.default, value: self.model.groupSession == nil)
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
