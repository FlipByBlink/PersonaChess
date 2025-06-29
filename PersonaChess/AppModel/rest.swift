import SwiftUI

extension AppModel {
    func rotateBoard() {
        withAnimation {
            self.sharedState.boardAngle += 90
        }
        self.sendMessage()
    }
    func upScale() {
        self.sharedState.viewScale *= 1.4
        self.sendMessage()
    }
    func downScale() {
        self.sharedState.viewScale *= 0.75
        self.sendMessage()
    }
    var upScalable: Bool {
        self.sharedState.viewScale < 50.0
    }
    var downScalable: Bool {
        self.sharedState.viewScale > 1.0
    }
    var isSharePlayStateNotSet: Bool {
        self.groupSession?.state == .joined
        &&
        self.sharedState.mode == .localOnly
    }
    var isSharedStateInvalidInSharePlay: Bool {
        self.groupSession != nil
        &&
        self.sharedState.mode == .localOnly
    }
    func disableInteractionDuringAnimation(_ action: Action) {
        guard action.hasAnimation else { return }
        Task {
            self.isAnimating = true
            try? await Task.sleep(for: .seconds(PieceAnimation.wholeDuration(action)))
            self.isAnimating = false
        }
    }
}
