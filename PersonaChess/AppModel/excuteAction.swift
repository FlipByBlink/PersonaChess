extension AppModel {
    func execute(_ action: Action, _ shouldSendMessage: Bool = true) {
        guard self.movingPieces.isEmpty else { return }
        switch action {
            case .tapPieceAndPick(let pieceID):
                self.sharedState.pieces.apply(action)
                //self.soundFeedback.select(tappedPieceBodyEntity, self.floorMode)
            case .tapSquareAndUnpick(_):
                self.sharedState.pieces.apply(action)
            case .tapPieceAndChangePickingPiece(let pickedPieceID, let tappedPieceID):
                self.sharedState.pieces.apply(action)
                //self.soundFeedback.select(tappedPieceBodyEntity, self.floorMode)
            case .tapSquareAndMove(let pieceID, to: let index):
                self.sharedState.pieces.apply(action)
            case .tapPieceAndMoveAndCapture(let pieceID, to: let index, let capturedPieceID):
                self.sharedState.pieces.apply(action)
            case .drag(let pieceID, let dragTranslation):
                //if Pieces.shouldPlaySound(bodyEntity) {
                //    self.soundFeedback.select(bodyEntity, self.floorMode)
                //}
                self.sharedState.pieces.apply(action)
            case .dropAndBack(_, _):
                self.sharedState.pieces.apply(action)
            case .dropAndMove(let pieceID, let draggingPosition, let index):
                self.sharedState.pieces.apply(action)
            case .dropAndMoveAndCapture(let pieceID, let sourceIndex, let targetIndex, let capturedPiece):
                self.sharedState.pieces.apply(action)
            case .undo:
                self.sharedState.pieces.apply(action)
            case .reset:
                self.sharedState.pieces.apply(action)
                if self.groupSession != nil { self.sharedState.mode = .sharePlay }
                self.soundFeedback.reset(self.entities.root)
        }
        
        self.updateEntities()
        
        if shouldSendMessage {
            self.sendMessage()
        }
    }
    
    private func playSound(_ action: Action) {
        
    }
}
