import SwiftUI

struct EntranceWindow: Scene {
    @EnvironmentObject var model: AppModel
    var body: some Scene {
        WindowGroup(id: "window") {
            EntranceView()
                .environmentObject(self.model)
        }
        .defaultSize(width: Self.size,
                     height: Self.size,
                     depth: Self.size)
        .windowResizability(.contentSize)
        .windowStyle(.volumetric)
    }
    static let size: CGFloat = 800
}

//Workaround: FullSpaceから改めてWindowを開いた際にEnvironmentObjectが機能しない場合があるので二重にenvironmentObject
