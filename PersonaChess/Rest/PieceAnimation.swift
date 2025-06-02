import SwiftUI

enum PieceAnimation {
    case vertical,
         horizontal,
         drop,
         fadeout
}

extension PieceAnimation {
    var duration: TimeInterval {
        switch self {
            case .vertical: 0.6
            case .horizontal: 1.0
            case .drop: 0.7
            case .fadeout: 0.3
        }
    }
    
    static func wholeDuration(_ action: Action) -> TimeInterval {
        switch action {
            case .tapPieceAndPick(_, _),
                    .tapPieceAndChangePickingPiece(_, _, _, _),
                    .tapSquareAndUnpick(_, _):
                Self.vertical.duration
                
            case .tapPieceAndMoveAndCapture(_, _, _, _),
                    .tapSquareAndMove(_, _, _):
                Self.horizontal.duration
                +
                Self.vertical.duration
                
            case .dropAndBack(_),
                    .dropAndMove(_, _),
                    .dropAndMoveAndCapture(_, _, _):
                Self.drop.duration
                
            default:
                { assertionFailure(); return 0.0 }()
        }
    }
    
    static func swiftUIAnimation_2DMode(_ action: Action?) -> Animation? { //TODO: iOS側へ移動させる
        switch action {
            case .tapPieceAndPick(_, _),
                    .tapPieceAndChangePickingPiece(_, _, _, _),
                    .tapSquareAndUnpick(_, _):
                Animation.easeInOut(duration: Self.vertical.duration)
            case .tapPieceAndMoveAndCapture(_, _, _, _),
                    .tapSquareAndMove(_, _, _):
                Animation.easeInOut(duration: Self.horizontal.duration + Self.vertical.duration)
            case .dropAndBack(_),
                    .dropAndMove(_, _),
                    .dropAndMoveAndCapture(_, _, _):
                Animation.easeInOut(duration: Self.drop.duration)
            case .beginDrag(_),
                    .undo,
                    .reset,
                    .none:
                nil
        }
    }
}
