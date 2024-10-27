import SwiftUI

struct PieceView_2DMode: View {
    @EnvironmentObject var model: AppModel
    var piece: Piece
    var index: Index
    
    @State private var delayingDownAnimation: Bool = false
    private let delayDuration: Double = 3.0
    
    var body: some View {
        ZStack {
            Rectangle()
                .opacity(0.001)
            Text(self.icon)
                .font(.system(size: self.isPicking_inVisually ? 48 : 32))
                .animation(.default, value: self.isPicking_inVisually)
//                .minimumScaleFactor(0.2)
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
        //.offset(z: self.isPicking ? 30 : 0)
        //        .border(.pink, width: self.isPicking ? 3 : 0)
        //        .animation(.default, value: self.delayingDownAnimation)
        //        .animation(.default, value: self.isPicking)
        .offset(self.offset)
        .animation(.spring(duration: self.delayDuration), value: self.offset)
//        .animation(.default, value: self.model.sharedState.pieces.isDragging)
        .frame(width: Size.Point.squareSize_2DMode,
               height: Size.Point.squareSize_2DMode)
        .onChange(of: self.isPicking) { _, newValue in
            if newValue {
                self.delayingDownAnimation = true
            } else {
                switch self.model.sharedState.pieces.currentAction {
                    case .tapSquareAndMove(_, _, _),
                            .tapPieceAndMoveAndCapture(_, _, _, _):
                        Task {
                            try? await Task.sleep(for: .seconds(self.delayDuration))
                            self.delayingDownAnimation = false
                        }
                    default:
                        self.delayingDownAnimation = false
                }
            }
        }
    }
}

private extension PieceView_2DMode {
    private var offset: CGSize {
        self.model.sharedState.pieces.offset_2DMode(self.piece, index)
    }
    private var icon: String {
        self.piece.chessmen.icon(isFilled: self.piece.side == .white)
    }
    private var isPicking_inVisually: Bool {
        self.isPicking
        ||
        self.delayingDownAnimation
    }
    private var isPicking: Bool {
        self.piece == self.model.sharedState.pieces.pickingPiece
    }
}
