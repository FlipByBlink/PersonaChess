import SwiftUI

@main
struct PersonaChessApp: App {
    @StateObject private var model = AppModel()
    
    var body: some Scene {
        WindowGroup(id: "volume") {
            VolumeView()
                .environmentObject(self.model)
        }
        .defaultSize(width: Size.Meter.board,
                     height: Size.Meter.board,
                     depth: Size.Meter.board,
                     in: .meters)
        .windowResizability(.contentSize)
        .windowStyle(.volumetric)
        
        ImmersiveSpace(id: "immersiveSpace") {
            FullSpaceView()
                .environmentObject(self.model)
                .handlesExternalEvents(preferring: [],
                                       allowing: [])
        }
    }
    
    init() {
        Piece.registerComponent()
        PieceOpacitySystem.registerSystem()
    }
}
