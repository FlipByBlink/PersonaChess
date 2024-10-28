import SwiftUI

struct PieceView_2DMode: View {
    @EnvironmentObject var model: AppModel
    var piece: Piece
    var index: Index
    
    var body: some View {
        ZStack {
            Rectangle()
                .opacity(0.001)
            Text(self.icon)
                .font(.system(size: 28 * (self.isPicking ? 1.4 : 1)))
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
        //.hoverEffect(isEnabled: !(self.model.isDragging || self.isPicking))
        .modifier(Self.OffsetZ(isPicking: self.isPicking))
        .offset(self.model.sharedState.pieces.offset_2DMode(self.piece, index))
        .animation(.default, value: self.model.sharedState.pieces.isDragging)
        .animation(.default, value: self.isPicking)
        .frame(width: Size.Point.squareSize_2DMode,
               height: Size.Point.squareSize_2DMode)
    }
}

private extension PieceView_2DMode {
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
