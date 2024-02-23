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
                        .frame(height: self.boardSize * 0.7)
                }
            }
            Spacer()
            ChessView()
            ToolbarsView()
        }
        .frame(width: self.boardSize, height: self.boardSize)
        .frame(depth: self.boardSize)
    }
}

private extension EntranceView {
    private var boardSize: CGFloat {
        Size.Point.board(self.physicalMetrics)
    }
    private var showHallView: Bool {
#if targetEnvironment(simulator)
        true
//        false
#else
        self.model.groupSession != nil
#endif
    }
}
