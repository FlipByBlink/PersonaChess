import SwiftUI

@main
struct PersonaChessApp: App {
    @StateObject private var model = AppModel()
    var body: some Scene {
        ImmersiveSpace {
            ContentView()
                .environmentObject(self.model)
        }
    }
    init() {
        Piece.registerComponent()
        PieceOpacitySystem.registerSystem()
    }
}
