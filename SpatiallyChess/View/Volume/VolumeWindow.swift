import SwiftUI

struct VolumeWindow: Scene {
    @EnvironmentObject var model: AppModel
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
}

//Workaround: FullSpaceから改めてWindowを開いた際にEnvironmentObjectが機能しない場合があるので二重にenvironmentObject
