import SwiftUI

struct VolumeWindow: Scene {
    private var model: AppModel
    var body: some Scene {
        WindowGroup(id: "volume") {
            VolumeView()
                .environmentObject(self.model)
        }
        .defaultSize(width: Size.Meter.board,
                     height: Size.Meter.board,
                     depth: Size.Meter.board,
                     in: .meters)
        .windowResizability(.contentSize)
        .windowStyle(.volumetric)
    }
    init(_ model: AppModel) {
        self.model = model
    }
}
