import SwiftUI

@main
struct IOSForDebugApp: App {
    @StateObject var model = AppModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(self.model)
        }
    }
    init() {
        Piece.registerComponent()
    }
}
