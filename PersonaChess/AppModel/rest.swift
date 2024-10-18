extension AppModel {
    func upScale() {
        self.sharedState.viewScale *= (self.floorMode ? 1.4 : 1.1)
        self.sendMessage()
    }
    func downScale() {
        self.sharedState.viewScale *= (self.floorMode ? 0.75 : 0.9)
        self.sendMessage()
    }
    func raiseBoard() {
        self.sharedState.viewHeight += 50
        self.sendMessage()
    }
    func lowerBoard() {
        self.sharedState.viewHeight -= 50
        self.sendMessage()
    }
    func lowerToFloor() {
        self.sharedState.viewHeight = 0
        self.sendMessage()
    }
    func separateFromFloor() {
        self.sharedState.viewHeight = Size.Point.defaultHeight
        if self.sharedState.viewScale > 3.0 {
            self.sharedState.viewScale = 1.0
        }
        self.sendMessage()
    }
    func changeExtraLargeMode() {
        self.lowerToFloor()
        self.sharedState.viewScale = 10.0
        self.sendMessage()
    }
    var upScalable: Bool {
        if self.floorMode {
            self.sharedState.viewScale < 50.0
        } else {
            self.sharedState.viewScale < 5.0
        }
    }
    var downScalable: Bool {
        self.sharedState.viewScale > 0.6
    }
    var isSharePlayStateNotSet: Bool {
        self.groupSession?.state == .joined
        &&
        self.sharedState.mode == .localOnly
    }
    var floorMode: Bool {
        self.isImmersiveSpaceShown
        &&
        self.sharedState.viewHeight == 0
    }
    var showProgressView: Bool {
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
