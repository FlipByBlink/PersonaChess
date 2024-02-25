import SwiftUI

struct VolumeWindow: Scene {
    @EnvironmentObject var model: AppModel
    var body: some Scene {
        WindowGroup(id: "volume") {
            VolumeView()
                .environmentObject(self.model) //※1
        }
        .defaultSize(width: Size.Meter.board + 0.25,
                     height: Size.Meter.board + 0.25,
                     depth: Size.Meter.board + 0.25,
                     in: .meters) //※2
        .windowResizability(.contentSize)
        .windowStyle(.volumetric)
    }
}

//==== ※1 workaround ====
//不具合: FullSpaceから改めてWindowを開いた際にEnvironmentObjectが機能しない場合がある
//対応: 冗長になるがここでもenvironmentObject(self.model)
//==== ※2 workaround ====
//不具合: visionOS1.0のバグでWindowZoomがvolumeに対して適切に動作しない不具合に対応するため少し大きめ(0.25m)に調整
//対応: volumeのサイズを元々少し大きめ(0.25m)に調整
//=======================
