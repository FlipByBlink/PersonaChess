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
            .toolbar { BottomButtons() }
            .animation(.default, value: self.model.isGuideMenuShown)
            .modifier(HandleGroupImmersion(.window))
            .modifier(DebugView())
            .volumeBaseplateVisibility(.hidden)
            .environment(\.sceneKind, .volume)
            .task { SharePlayProvider.registerGroupActivity() }
    }
}
