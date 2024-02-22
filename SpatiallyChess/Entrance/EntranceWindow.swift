import SwiftUI

struct EntranceWindow: Scene {
    @EnvironmentObject var model: AppModel
    var body: some Scene {
        WindowGroup(id: "window") {
            EntranceView()
                .environmentObject(self.model)
        }
        .defaultSize(width: Self.defaultSize,
                     height: Self.defaultSize,
                     depth: Self.defaultSize,
                     in: .meters)
        .windowStyle(.volumetric)
    }
}

private extension EntranceWindow {
    private static var defaultSize: CGFloat { //TODO: 再検討
        (.init(Size.Meter.square) * 8)
        +
        0.03
//        +
//        (Size.Meter.boardInnerPadding * 2)
//        +
//        (Size.Meter.boardOuterPadding * 2)
    }
}

//Workaround: FullSpaceから改めてWindowを開いた際にEnvironmentObjectが機能しない場合があるので二重にenvironmentObject
