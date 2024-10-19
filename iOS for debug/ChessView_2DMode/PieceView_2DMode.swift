import SwiftUI

struct PieceView_2DMode: View {
    @EnvironmentObject var model: AppModel
    var piece: Piece
    var index: Index
    var body: some View {
        ZStack {
            Color.clear
            Text(self.piece.chessmen.icon(isFilled: self.piece.side == .black))
                .font(.system(size: 60))
                .minimumScaleFactor(0.2)
        }
        .overlay(alignment: .topTrailing) {
            if self.model.sharedState.pieces.promotions[self.piece] == true {
                Circle().frame(width: 10, height: 10).padding(4)
            }
        }
        .contentShape(.rect)
        .onTapGesture { self.model.handle(.tapPiece(self.piece)) }
        .border(.pink, width: self.model.sharedState.pieces.pickingPiece == self.piece ? 3 : 0)
        .offset(self.model.sharedState.pieces.offset_2DMode(self.piece, index))
        .animation(.default, value: self.model.sharedState.pieces.isDragging)
    }
}
