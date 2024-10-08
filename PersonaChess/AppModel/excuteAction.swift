extension AppModel {
    func execute(_ action: Action, _ shouldSendMessage: Bool = true) {
        guard self.movingPieces.isEmpty else { return }
        
        self.sharedState.logIfNecessary(action)
        
        self.sharedState.pieces.apply(action)
        
        if case .undo = action { self.sharedState.undo() }
        
        if action == .reset, self.groupSession != nil {
            self.sharedState.mode = .sharePlay
        }
        
        self.entities.update(self.sharedState.pieces)
        
        if shouldSendMessage { self.sendMessage() }
    }
}
