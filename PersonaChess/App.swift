import SwiftUI

@main
struct PersonaChessApp: App {
    @StateObject private var model = AppModel()
    
    var body: some Scene {
        WindowGroup(id: "volumeWindow") {
            VolumeWindowView()
        }
        .windowStyle(.volumetric)
        .volumeWorldAlignment(.gravityAligned)
        .environmentObject(self.model)
        
        ImmersiveSpace(id: "immersiveSpace") {
            ImmersiveSpaceView()
        }
        .environmentObject(self.model)
    }
    
    init() {
        Piece.registerComponent()
    }
}
