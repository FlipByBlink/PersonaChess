import SwiftUI
import RealityKit

struct EntranceView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow
    var body: some View {
        VStack(spacing: 12) {
            if self.showSharePlayMenu {
                SharePlayMenu()
                    .frame(height: self.boardSize * 0.7)
            }
            Spacer()
            ChessView()
            ToolbarsView(targetScene: .window)
        }
        .frame(width: self.boardSize, height: self.boardSize)
        .frame(depth: self.boardSize)
        .onChange(of: self.model.queueToOpenScene) { _, newValue in
            if newValue == .fullSpace {
                Task {
                    await self.openImmersiveSpace(id: "immersiveSpace")
                    self.dismissWindow(id: "window")
                    self.model.clearQueueToOpenScene()
                }
            }
        }
    }
}

private extension EntranceView {
    private var boardSize: CGFloat {
        Size.Point.board(self.physicalMetrics)
    }
    private var showSharePlayMenu: Bool {
#if targetEnvironment(simulator)
        true
//        false
#else
        self.model.groupSession == nil
#endif
    }
}
