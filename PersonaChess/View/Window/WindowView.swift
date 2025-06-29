import SwiftUI

struct WindowView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        ChessView()
            .offset(y: -100)
            .frame(height: Size.Point.board(self.physicalMetrics),
                   alignment: .bottom)
            .ornament(attachmentAnchor: .scene(.topBack)) { GuideMenuView() }
            .toolbar { BottomButtons() }
            .modifier(HandleGroupImmersion(.window))
            .modifier(DebugView())
            .volumeBaseplateVisibility(.hidden)
            .environment(\.sceneKind, .window)
            .task { SharePlayProvider.registerGroupActivity() }
    }
}
