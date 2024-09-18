import SwiftUI

@main
struct PersonaChessApp: App {
    @StateObject private var model = AppModel()
    @AppStorage("userAppleID") var storedAppleID: String = ""

    var body: some Scene {
        WindowGroup(id: "centerWindow") {
            if storedAppleID.isEmpty {
                AppleIDEntryView()
                    .environmentObject(model)
            } else {
                ContentView()
                    .environmentObject(model)
            }
        }
        .windowResizability(.contentSize)

        ImmersiveSpace(id: "immersiveSpace") {
            ImmersiveSpaceView()
                .environmentObject(model)
        }
    }

    init() {
        Piece.registerComponent()
        PieceOpacitySystem.registerSystem()
    }
}
