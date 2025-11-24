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
                    .tapSquareAndChangePickingPiece(_, _, _, _),
                    .tapSquareAndUnpick(_, _):
                Self.vertical.duration
                
            case .tapSquareAndMoveAndCapture(_, _, _, _),
                    .tapSquareAndMove(_, _, _):
                Self.horizontal.duration
                +
                Self.vertical.duration
                
            case .dropAndBack(_),
                    .dropAndMove(_, _),
                    .dropAndMoveAndCapture(_, _, _):
                Self.drop.duration
                
            case .remove(_):
                Self.fadeout.duration
                
            default:
                { assertionFailure(); return 0.0 }()
        }
    }
}
