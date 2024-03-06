import SwiftUI

struct VolumeWindow: Scene {
    @EnvironmentObject var model: AppModel
    var body: some Scene {
        WindowGroup(id: "volume") {
            VolumeView()
                .environmentObject(self.model) //※1
        }
        .defaultSize(width: Size.Meter.board,
                     height: Size.Meter.board,
                     depth: Size.Meter.board,
                     in: .meters)
        .windowResizability(.contentSize)
        .windowStyle(.volumetric)
    }
}

//==== ※1 workaround ====
//不具合: FullSpaceから改めてWindowを開いた際にEnvironmentObjectが機能しない場合がある
//対応: 冗長になるがここでもenvironmentObject(self.model)
//=======================
