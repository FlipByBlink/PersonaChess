import SwiftUI

extension ImmersiveSpaceView {
    var scaleAnchor: UnitPoint3D {
        switch self.model.sharedState.boardPosition {
            case .center: .center
            case .up: .bottomFront
            case .down: .bottomBack
            case .right: .bottomLeading
            case .left: .bottomTrailing
        }
    }
}
