extension AppModel {
    func execute(_ action: Action) {
        guard self.movingPieces.isEmpty else { return }
        switch action {
            case .tapPiece(let tappedPieceBodyEntity):
                let tappedPiece: Piece = tappedPieceBodyEntity.parent!.components[Piece.self]!
                if let pickedPieceEntity = self.entities.pickedPieceEntity {
                    let pickedPiece: Piece = pickedPieceEntity.components[Piece.self]!
                    if tappedPiece.side == pickedPiece.side {
                        self.sharedState.pieces.pick(tappedPiece.id)
                        self.sharedState.pieces.unpick(pickedPiece.id)
                        self.soundFeedback.select(tappedPieceBodyEntity, self.floorMode)
                    } else {
                        self.sharedState.pieces.appendLog()
                        self.sharedState.pieces.movePiece(pickedPiece.id,
                                                          to: tappedPiece.index)
                        self.sharedState.pieces.removePiece(tappedPiece.id)
                    }
                } else {
                    self.sharedState.pieces.pick(tappedPiece.id)
                    self.soundFeedback.select(tappedPieceBodyEntity, self.floorMode)
                }
            case .tapSquare(let index):
                let pickedPieceEntity = self.entities.pickedPieceEntity!
                self.sharedState.pieces.appendLog()
                self.sharedState.pieces.movePiece(pickedPieceEntity.components[Piece.self]!.id,
                                                  to: index)
            case .drag(let bodyEntity, translation: let dragTranslation):
                guard self.entities.pickedPieceEntity == nil else { return }
                if Pieces.shouldPlaySound(bodyEntity) {
                    self.soundFeedback.select(bodyEntity, self.floorMode)
                }
                self.sharedState.pieces.drag(bodyEntity, dragTranslation)
            case .drop(let bodyEntity):
                if Pieces.shouldLog(bodyEntity) {
                    self.sharedState.pieces.appendLog()
                }
                self.sharedState.pieces.drop(bodyEntity)
            case .undo:
                self.sharedState.pieces.undo()
            case .reset:
                self.sharedState.pieces.appendLog()
                self.sharedState.pieces.setPreset()
                if self.groupSession != nil { self.sharedState.mode = .sharePlay }
                self.soundFeedback.reset(self.entities.root)
        }
        
        self.updateEntities()
        self.sendMessage()
    }
}
