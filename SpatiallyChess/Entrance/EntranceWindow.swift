import SwiftUI

struct EntranceWindow: Scene {
    @EnvironmentObject var model: AppModel
    var body: some Scene {
        WindowGroup(id: "window") {
            EntranceView()
                .environmentObject(self.model)
        }
        .defaultSize(width: Size.Meter.volume,
                     height: Size.Meter.volume,
                     depth: Size.Meter.volume,
                     in: .meters)
        .windowResizability(.contentSize)
        .windowStyle(.volumetric)
    }
}

//Workaround: FullSpaceから改めてWindowを開いた際にEnvironmentObjectが機能しない場合があるので二重にenvironmentObject
