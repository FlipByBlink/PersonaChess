import SwiftUI

struct BoardView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<8, id: \.self) { column in
                VStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { row in
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
        .opacity(self.model.floorMode ? 0.25 : 1)
        .modifier(Self.SharePlayStateLoading())
        .rotation3DEffect(.degrees(90), axis: .x)
    }
}

private extension BoardView {
    private func maskView() -> some View {
        RoundedRectangle(cornerRadius: self.model.floorMode ? 0 : 24,
                         style: .continuous)
    }
    private func boardOutlineView() -> some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .stroke(Color(white: 0.75), lineWidth: 3)
            .opacity(self.model.floorMode ? 0 : 1)
    }
    private var paddingSize: CGFloat {
        if self.model.floorMode {
            0
        } else {
            Size.Point.boardInnerPadding(self.physicalMetrics)
        }
    }
    private var boardSize: CGFloat {
        if self.model.floorMode {
            Size.Point.boardInFloorMode(self.physicalMetrics)
        } else {
            Size.Point.board(self.physicalMetrics)
        }
    }
    private struct SharePlayStateLoading: ViewModifier {
        @EnvironmentObject var model: AppModel
        func body(content: Content) -> some View {
            content
                .overlay {
                    if self.model.isSharePlayStateNotSet {
                        ProgressView()
                            .offset(z: 10)
                    }
                }
                .animation(.default, value: self.model.isSharePlayStateNotSet)
        }
    }
}
