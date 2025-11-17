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
        .mask(alignment: .center) { self.maskView() }
        .overlay { self.boardOutlineView() }
        .padding(self.paddingSize)
        .frame(width: self.boardSize, height: self.boardSize)
        .glassBackgroundEffect()
        .modifier(MenuDuringImmersiveSpaceMode())
        .opacity(self.sceneKind == .immersiveSpace ? 0.25 : 1)
        .rotation3DEffect(.degrees(90), axis: .x)
    }
}


private extension BoardView {
    private func maskView() -> some View {
        RoundedRectangle(cornerRadius: self.sceneKind == .window ? 24 : 0,
                         style: .continuous)
    }
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
                Size.Point.boardInImmersiveSpace(self.physicalMetrics)
            case .window:
                Size.Point.board(self.physicalMetrics)
        }
    }
}
