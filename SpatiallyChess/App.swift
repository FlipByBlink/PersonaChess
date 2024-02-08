import SwiftUI

@main
struct SpatiallyChessApp: App {
    var body: some Scene {
        ImmersiveSpace {
            ContentView()
        }
    }
    init() {
        Piece.registerComponent()
        PieceOpacitySystem.registerSystem()
    }
}
