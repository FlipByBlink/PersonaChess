import SwiftUI

struct PieceView_2DMode: View {
    @EnvironmentObject var model: AppModel
    var piece: Piece
    var dragState: DragState?
    var body: some View {
        if let offset {
            ZStack {
                Rectangle()
                    .opacity(0.001)
                Text(self.icon)
                    .font(.system(size: 36 * (self.isPicking ? 1.6 : 1)))
            }
            .overlay(alignment: .topTrailing) {
                if self.model.sharedState.pieces.promotions[self.piece] == true {
                    Circle()
                        .frame(width: 10, height: 10)
                        .padding(6)
                }
            }
            .contentShape(.rect)
            .onTapGesture { self.model.handle(.tapPiece(self.piece)) }
            .modifier(Self.OffsetZ(isPicking: self.isPicking))
            .offset(offset)
            .frame(width: Size.Point.squareSize_2DMode,
                   height: Size.Point.squareSize_2DMode)
        }
    }
}

private extension PieceView_2DMode {
    private var offset: CGSize? {
        self.model.sharedState.pieces.offset_2DMode(self.piece,
                                                    dragState: self.dragState)
    }
    private var icon: String {
        self.piece.chessmen.icon(isFilled: self.piece.side == .white)
    }
    private var isPicking: Bool {
        self.piece == self.model.sharedState.pieces.pickingPiece
    }
    private struct OffsetZ: ViewModifier {
        var isPicking: Bool
        func body(content: Content) -> some View {
            content
#if os(visionOS)
                .offset(z: self.isPicking ? 30 : 0)
#endif
        }
    }
}
