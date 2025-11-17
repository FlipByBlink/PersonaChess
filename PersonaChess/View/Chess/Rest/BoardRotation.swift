import SwiftUI

struct BoardRotation: ViewModifier {
    @EnvironmentObject var model: AppModel
    @Environment(\.sceneKind) var sceneKind
    private var angle: Double {
        switch self.sceneKind {
            case .window:
                self.model.isImmersiveSpaceShown ? 0 : self.model.sharedState.boardAngle
            case .immersiveSpace:
                self.model.isImmersiveSpaceShown ? self.model.sharedState.boardAngle : 0
        }
    }
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(self.angle), axis: .y)
            .animation(.default, value: self.angle)
    }
}
