import Foundation

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
            case .dropAndBack(_, _, _),
                    .dropAndMove(_, _, _, _),
                    .dropAndMoveAndCapture(_, _, _, _, _):
                Self.drop.duration
            default:
                { assertionFailure(); return 0.0 }()
        }
    }
}
