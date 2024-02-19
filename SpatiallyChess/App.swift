import SwiftUI

@main
struct SpatiallyChessApp: App {
    @StateObject private var model: AppModel = .init()
    var body: some Scene {
        EntranceWindow()
            .environmentObject(self.model)
        ImmersiveSpace(id: "immersiveSpace") {
            FullSpaceView()
                .environmentObject(self.model)
        }
    }
    init() {
        Piece.registerComponent()
        PieceOpacitySystem.registerSystem()
    }
}
