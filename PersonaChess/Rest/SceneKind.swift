import SwiftUI

enum SceneKind {
    case window,
         immersiveSpace
}

extension EnvironmentValues {
    @Entry var sceneKind: SceneKind = .window
}
