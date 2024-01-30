import SwiftUI

@main
struct SpatialChessApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .border(.pink, width: 3)
                .overlay {
                    Circle()
                        .frame(width: 10, height: 10)
                }
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1400,
                     height: 500,
                     depth: 1400)
    }
}
