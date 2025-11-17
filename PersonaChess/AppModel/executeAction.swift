extension AppModel {
    func execute(_ action: Action) {
        
        guard !self.isAnimating else { return }
        
        self.sharedState.logIfNecessary(action)
        
        self.sharedState.pieces.apply(action)
        
        if case .undo = action { self.sharedState.undo() }
        
        self.disableInteractionDuringAnimation(action)
        
        self.entities.update(self.sharedState.pieces)
        
        self.sendMessage()
    }
    
    func executeDrag(_ state: DragState) {
        
        self.entities.dragUpdate(self.sharedState.pieces,
                                 state)
        
        self.sendMessage(dragState: state)
    }
}
