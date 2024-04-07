import SwiftUI

@main
struct IOSForDebugApp: App {
    @StateObject private var model: AppModel = .init()
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
