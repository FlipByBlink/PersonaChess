extension AppModel {
    func handle(_ interaction: Interaction) {
        let action: Action
        
        switch interaction {
            case .tapPiece(let tappedPieceBodyEntity):
                let tappedPiece: Piece = tappedPieceBodyEntity.parent!.components[Piece.self]!
                if let pickedPiece = self.sharedState.pieces.activeOnly.first(where: { $0.picked }) {
                    if tappedPiece.side == pickedPiece.side {
                        action = .tapPieceAndChangePickingPiece(ex: pickedPiece.id, new: tappedPiece.id)
                    } else {
                        action = .tapPieceAndMoveAndCapture(tappedPiece.id,
                                                      to: tappedPiece.index,
                                                      capturedPiece: tappedPiece.id)
                    }
                } else {
                    action = .tapPieceAndPick(tappedPiece.id)
                }
            case .tapSquare(let index):
                guard let pickedPiece = self.sharedState.pieces.activeOnly.first(where: { $0.picked }) else {
                    fatalError()
                }
                if index == pickedPiece.index {
                    action = .tapSquareAndUnpick(pickedPiece.id)
                } else {
                    action = .tapSquareAndMove(pickedPiece.id, to: index)
                }
            case .drag(let gestureValue):
                let dragTranslation = gestureValue.convert(gestureValue.translation3D,
                                                           from: .local,
                                                           to: self.entities.root)
                let draggedPiece = gestureValue.entity.parent!.components[Piece.self]!
                action = .drag(draggedPiece.id,
                               translation: dragTranslation)
            case .drop(let gestureValue):
                let dragTranslation = gestureValue.convert(gestureValue.translation3D,
                                                           from: .local,
                                                           to: self.entities.root)
                let droppedPiece = gestureValue.entity.parent!.components[Piece.self]!
                let targetingIndex = droppedPiece.dragTargetingIndex()
                if droppedPiece.index == targetingIndex {
                    action = .dropAndBack(droppedPiece.id,
                                           from: dragTranslation)
                } else {
                    if let capturedPiece = self.sharedState.pieces.activeOnly.first(where: { $0.index == targetingIndex }) {
                        action = .dropAndMoveAndCapture(droppedPiece.id,
                                                       from: dragTranslation,
                                                       to: targetingIndex,
                                                       capturedPiece: capturedPiece.id)
                    } else {
                        action = .dropAndMove(droppedPiece.id,
                                             from: dragTranslation,
                                             to: targetingIndex)
                    }
                }
        }
        
        self.execute(action)
    }
}
