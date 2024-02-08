import SwiftUI

@main
struct SpatiallyChessApp: App {
    var body: some Scene {
        ImmersiveSpace {
            ContentView()
        }
    }
    init() {
        PieceStateComponent.registerComponent()
        PieceOpacitySystem.registerSystem()
    }
}
