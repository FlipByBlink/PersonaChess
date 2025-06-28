import SwiftUI

struct ImmersiveSpaceView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        ChessView()
            .scaleEffect(self.model.sharedState.viewScale,
                         anchor: self.scaleAnchor)
            .offset(z: self.zOffset)
            .offset(x: self.xOffset)
            .animation(.default, value: self.model.sharedState.viewScale)
            .modifier(HandleGroupImmersion(.immersiveSpace))
            .environment(\.sceneKind, .immersiveSpace)
            .handlesExternalEvents(preferring: [], allowing: [])
            .onAppear { self.model.isImmersiveSpaceShown = true }
            .onDisappear { self.model.isImmersiveSpaceShown = false }
    }
}
