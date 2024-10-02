extension AppModel {
    func execute(_ action: Action, _ shouldSendMessage: Bool = true) {
        guard self.movingPieces.isEmpty else { return }
        
        self.sharedState.pieces.apply(action)
        
        if case .drag(_, _, _) = action {
            //if Pieces.shouldPlaySound(bodyEntity) {
            //    self.soundFeedback.select(bodyEntity, self.floorMode)
            //}
        }
        
        if action == .reset, self.groupSession != nil {
            self.sharedState.mode = .sharePlay
        }
        
        self.updateEntities()
        
        if shouldSendMessage {
            self.sendMessage()
        }
    }
}
