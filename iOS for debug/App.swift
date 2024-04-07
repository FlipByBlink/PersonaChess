import SwiftUI

@main
struct IOSForDebugApp: App {
    @StateObject var model: AppModel = .init()
    var body: some Scene {
        WindowGroup(id: "volume") {
            ContentView()
                .environmentObject(self.model)
        }
    }
    init() {
        Piece.registerComponent()
    }
}
