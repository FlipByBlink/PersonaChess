import SwiftUI

@main
struct SpatialChessApp: App {
    var body: some Scene {
        ImmersiveSpace {
            ContentView()
        }
    }
    init() {
        PieceStateComponent.registerComponent()
        PieceLooksSystem.registerSystem()
    }
}
