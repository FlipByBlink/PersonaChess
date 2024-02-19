import SwiftUI

struct EntranceWindow: Scene {
    var body: some Scene {
        WindowGroup(id: "window") {
            EntranceView()
        }
        .defaultSize(width: Self.size,
                     height: Self.size,
                     depth: Self.size)
        .windowResizability(.contentSize)
        .windowStyle(.volumetric)
    }
    static let size: CGFloat = 800
}
