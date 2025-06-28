import SwiftUI

struct VolumeWindowView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        ChessView()
            .offset(y: -100)
            .frame(height: Size.Point.board(self.physicalMetrics),
                   alignment: .bottom)
            .background { GuideMenuView() }
            .toolbar {
                ToolbarItemGroup(placement: .bottomOrnament) {
                    OpenAndDismiss3DSpaceButton()
                    RotateBoardButton()
                    RemoveButton()
                    UndoButton()
                    ResetButton()
                    OpenGuideMenuButton()
                }
            }
            .animation(.default, value: self.model.isGuideMenuShown)
            .volumeBaseplateVisibility(.hidden)
            .environment(\.sceneKind, .volume)
            .task { SharePlayProvider.registerGroupActivity() }
    }
}


