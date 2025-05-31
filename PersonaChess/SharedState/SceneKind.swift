import SwiftUI

enum SceneKind {
    case volume,
         immersiveSpace
}

extension EnvironmentValues {
    @Entry var sceneKind: SceneKind = .volume
}
