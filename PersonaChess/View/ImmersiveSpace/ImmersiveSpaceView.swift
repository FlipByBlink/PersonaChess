import SwiftUI

struct ImmersiveSpaceView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        ChessView()
            .scaleEffect(self.model.sharedState.viewScale,
                         anchor: self.anchor)
            .offset(z: self.zOffset)
            .offset(x: self.xOffset)
            .animation(.default, value: self.model.sharedState.viewScale)
            .overlay { ToolbarViewOnHand() }
            .overlay { SpatialSuggestionDialog() }
            .overlay { RecordingRoom() }
            .environment(\.sceneKind, .immersiveSpace)
            .handlesExternalEvents(preferring: [], allowing: [])
            .onAppear { self.model.isImmersiveSpaceShown = true }
            .onDisappear { self.model.isImmersiveSpaceShown = false }
    }
}

private extension ImmersiveSpaceView {
    private var boardSize: CGFloat { Size.Point.board(self.physicalMetrics) }
    private var zOffset: CGFloat {
        if self.model.spatialSharePlaying == true {
            0
        } else {
            {
                switch self.model.sharedState.boardPosition {
                    case .up: -self.boardSize
                    case .down: self.boardSize
                    default: 0
                }
            }()
            -
            Size.Point.nonSpatialZOffset
        }
    }
    private var xOffset: CGFloat {
        switch self.model.sharedState.boardPosition {
            case .right: self.boardSize
            case .left: -self.boardSize
            default: 0
        }
    }
    private var anchor: UnitPoint3D {
        switch self.model.sharedState.boardPosition {
            case .center: .center
            case .up: .bottomFront
            case .down: .bottomBack
            case .right: .bottomLeading
            case .left: .bottomTrailing
        }
    }
}
