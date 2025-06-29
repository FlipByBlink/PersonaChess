import SwiftUI

extension ImmersiveSpaceView {
    var zOffset: CGFloat {
        {
            switch self.model.sharedState.boardPosition {
                case .up: -self.boardSize
                case .down: self.boardSize
                default: 0
            }
        }()
        +
        {
            if self.model.spatialSharePlaying == true {
                0
            } else {
                -Size.Point.nonSpatialZOffset
            }
        }()
    }
    
    var xOffset: CGFloat {
        switch self.model.sharedState.boardPosition {
            case .right: self.boardSize
            case .left: -self.boardSize
            default: 0
        }
    }
    
    private var boardSize: CGFloat { Size.Point.board(self.physicalMetrics) }
}
