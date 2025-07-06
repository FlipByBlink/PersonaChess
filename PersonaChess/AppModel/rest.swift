import SwiftUI

extension AppModel {
    func rotateBoard() {
        if self.sharedState.boardAngle >= 270 {
            self.sharedState.boardAngle = .zero
        } else {
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
    func changeBoardPosition(_ boardPosition: BoardPosition) {
        if self.sharedState.boardPosition == boardPosition {
            self.sharedState.boardPosition = .center
        } else {
            self.sharedState.boardPosition = boardPosition
        }
        self.sendMessage()
    }
    var upScalable: Bool {
        self.sharedState.viewScale < 50.0
    }
    var downScalable: Bool {
        self.sharedState.viewScale > 1.0
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
