import SwiftUI

@main
struct iOS_for_debugApp: App {
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
