import SwiftUI
import RealityKit

struct EntranceView: View {
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        VStack(spacing: 12) {
            Group {
                if self.showHallView {
                    HallView()
                } else {
                    SharePlayMenu()
                        .frame(height: self.volumeSize * 0.7)
                }
            }
            Spacer()
            ChessView()
            ToolbarsView()
        }
        .frame(width: Size.Point.board(self.physicalMetrics),
               height: Size.Point.board(self.physicalMetrics))
        .offset(z: Size.Point.boardOuterPadding(self.physicalMetrics))
        .frame(width: self.volumeSize,
               height: self.volumeSize)
        .frame(depth: self.volumeSize)
    }
    private var volumeSize: CGFloat {
        Size.Point.volume(self.physicalMetrics)
    }
}

private extension EntranceView {
    private var showHallView: Bool {
#if targetEnvironment(simulator)
        true
//        false
#else
        self.model.groupSession != nil
#endif
    }
}
