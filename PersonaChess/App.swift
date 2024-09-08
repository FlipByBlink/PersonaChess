import SwiftUI

@main
struct PersonaChessApp: App {
    @StateObject private var model = AppModel()
    
    var body: some Scene {
        WindowGroup(id: "centerWindow") {
            CenterWindowView()
                .environmentObject(self.model)
        }
        .windowResizability(.contentSize)
        
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
