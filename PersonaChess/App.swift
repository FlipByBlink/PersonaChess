import SwiftUI

@main
struct PersonaChessApp: App {
    @StateObject private var model = AppModel()
    var body: some Scene {
        ImmersiveSpace {
            ContentView()
                .environmentObject(self.model)
                .task {
                    try? await Task.sleep(for: .seconds(2))
                    self.model.lowerToFloor()
                }
        }
    }
    init() {
        Piece.registerComponent()
        PieceOpacitySystem.registerSystem()
    }
}
