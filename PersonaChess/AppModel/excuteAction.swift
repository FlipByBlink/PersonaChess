extension AppModel {
    func execute(_ action: Action,
                 _ shouldSendMessage: Bool = true) {
        
        guard !self.isAnimating else { return }
        
        self.sharedState.logIfNecessary(action)
        
        self.sharedState.pieces.apply(action)
        
        if case .undo = action { self.sharedState.undo() }
        
        if action == .reset, self.groupSession != nil {
            self.sharedState.mode = .sharePlay
        }
        
        self.disableInteractionDuringAnimation(action)
        
        self.entities.update(self.sharedState.pieces)
        
        if shouldSendMessage { self.sendMessage() }
    }
    
    func execute(dragAction: Action,
                 _ shouldSendMessage: Bool = true) {
        
        self.sharedState.pieces.apply(dragAction)
        
        self.entities.dragUpdate(self.sharedState.pieces,
                                 dragAction)
        
        if shouldSendMessage { self.sendMessage() }
    }
}
