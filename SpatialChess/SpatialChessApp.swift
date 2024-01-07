import SwiftUI

@main
struct SpatialChessApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: チェスボードのサイズ.ボードの一辺の大きさ,
                     height: チェスボードのサイズ.ボードの一辺の大きさ,
                     depth: チェスボードのサイズ.ボードの一辺の大きさ)
    }
}
