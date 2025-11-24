import SwiftUI

extension PieceAnimation {
    static func swiftUIAnimation_2DMode(_ action: Action?) -> Animation? {
        switch action {
            case .tapPieceAndPick(_, _),
                    .tapSquareAndChangePickingPiece(_, _, _, _),
                    .tapSquareAndUnpick(_, _):
                Animation.easeInOut(duration: Self.vertical.duration)
            case .tapSquareAndMoveAndCapture(_, _, _, _),
                    .tapSquareAndMove(_, _, _):
                Animation.easeInOut(duration: Self.horizontal.duration + Self.vertical.duration)
            case .dropAndBack(_),
                    .dropAndMove(_, _),
                    .dropAndMoveAndCapture(_, _, _):
                Animation.easeInOut(duration: Self.drop.duration)
            case .beginDrag(_),
                    .remove(_),
                    .undo,
                    .reset,
                    .none:
                nil
        }
    }
}
