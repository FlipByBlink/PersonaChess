import SwiftUI

@main
struct IOSAppForDebug: App {
    @StateObject private var model = AppModel()
    
    var body: some Scene {
        WindowGroup(id: "volumeWindow") {
            ContentView()
                .environmentObject(self.model)
        }
    }
    
    init() {
        Piece.registerComponent()
    }
}
