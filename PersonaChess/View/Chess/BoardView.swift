import SwiftUI

struct BoardView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    @Environment(\.sceneKind) var sceneKind
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<8) { column in
                VStack(spacing: 0) {
                    ForEach(0..<8) { row in
                        SquareView(row, column)
                    }
                }
            }
        }
        .overlay { self.boardOutlineView() }
        .padding(self.paddingSize)
        .glassBackgroundEffect()
        .allowsHitTesting(self.model.sharedState.pieces.isPicking)
        .frame(width: self.boardSize, height: self.boardSize)
        .frame(height: 0)
        .opacity(self.sceneKind == .immersiveSpace ? 0.25 : 1)
        .modifier(MenuDuringGroundMode())
        .rotation3DEffect(.degrees(90), axis: .x)
    }
}


private extension BoardView {
    private func boardOutlineView() -> some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .stroke(Color(white: 0.75), lineWidth: 3)
            .opacity(self.sceneKind == .immersiveSpace ? 0 : 1)
    }
    private var paddingSize: CGFloat {
        if self.sceneKind == .immersiveSpace {
            0
        } else {
            Size.Point.boardInnerPadding(self.physicalMetrics)
        }
    }
    private var boardSize: CGFloat {
        switch self.sceneKind {
            case .immersiveSpace:
                Size.Point.boardInGroundMode(self.physicalMetrics)
            case .window:
                Size.Point.board(self.physicalMetrics)
        }
    }
}
