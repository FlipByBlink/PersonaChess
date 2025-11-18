import SwiftUI

struct WindowView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        ChessView()
            .offset(y: -100)
            .frame(height: Size.Point.board(self.physicalMetrics),
                   alignment: .bottom)
            .modifier(GuideMenu())
            .supportedVolumeViewpoints(.all)
            .toolbar { BottomButtons() }
            .modifier(HandleGroupImmersion(.window))
            .volumeBaseplateVisibility(.hidden)
            .preferredWindowClippingMargins(.all, 300)
            .environment(\.sceneKind, .window)
            .modifier(GroupActivityRegistration())
    }
}
