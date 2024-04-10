import SwiftUI

@main
struct PersonaChessApp: App {
    @StateObject private var model = AppModel()
    var body: some Scene {
        VolumeWindow(self.model)
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
