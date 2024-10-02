import simd

extension AppModel {
    func handle(_ interaction: Interaction) {
        let action: Action
        
        switch interaction {
            case .tapPiece(let tappedPieceBodyEntity):
                let tappedPieceID = tappedPieceBodyEntity.parent!.components[Piece.ID.self]!
                let tappedPiece = self.sharedState.pieces[tappedPieceID]
                if self.sharedState.pieces.currentAction?.isPicking == true {
                    guard let pickingPiece = self.sharedState.pieces.pickingPiece else {
                        assertionFailure(); return
                    }
                    if tappedPiece.side == pickingPiece.side {
                        action = .tapPieceAndChangePickingPiece(exPickedPieceID: pickingPiece.id,
                                                                exPickedPieceIndex: pickingPiece.index!,
                                                                newPickedPieceID: tappedPiece.id,
                                                                newPickedPieceIndex: tappedPiece.index!)
                    } else {
                        action = .tapPieceAndMoveAndCapture(pickedPieceID: pickingPiece.id,
                                                            pickedPieceIndex: pickingPiece.index!,
                                                            capturedPieceID: tappedPiece.id,
                                                            capturedPieceIndex: tappedPiece.index!)
                    }
                } else {
                    action = .tapPieceAndPick(tappedPiece.id, tappedPiece.index!)
                }
            case .tapSquare(let tappedIndex):
                guard let pickedPiece = self.sharedState.pieces.pickingPiece else {
                    assertionFailure(); return
                }
                if tappedIndex == pickedPiece.index {
                    action = .tapSquareAndUnpick(pickedPiece.id,
                                                 pickedPiece.index!)
                } else {
                    action = .tapSquareAndMove(pickedPiece.id,
                                               exIndex: pickedPiece.index!,
                                               newIndex: tappedIndex)
                }
            case .drag(let gestureValue):
                let dragTranslation = gestureValue.convert(gestureValue.translation3D,
                                                           from: .local,
                                                           to: self.entities.root)
                let draggedPieceID = gestureValue.entity.parent!.components[Piece.ID.self]!
                let draggedPiece = self.sharedState.pieces[draggedPieceID]
                action = .drag(draggedPiece.id,
                               sourceIndex: draggedPiece.index!,
                               dragTranslation: dragTranslation)
            case .drop(let gestureValue):
                let dragTranslation = gestureValue.convert(gestureValue.translation3D,
                                                           from: .local,
                                                           to: self.entities.root)
                let droppedPieceID = gestureValue.entity.parent!.components[Piece.ID.self]!
                let droppedPiece = self.sharedState.pieces[droppedPieceID]
                let targetingIndex = self.dragTargetingIndex(dragTranslation: dragTranslation,
                                                             sourceIndex: droppedPiece.index!)
                if droppedPiece.index == targetingIndex {
                    action = .dropAndBack(droppedPiece.id,
                                          sourceIndex: droppedPiece.index!,
                                          dragTranslation: dragTranslation)
                } else {
                    if let capturedPiece = self.sharedState.pieces[targetingIndex] {
                        action = .dropAndMoveAndCapture(droppedPiece.id,
                                                        sourceIndex: droppedPiece.index!,
                                                        dragTranslation: dragTranslation,
                                                        capturedPieceID: capturedPiece.id,
                                                        capturedPieceIndex: capturedPiece.index!)
                    } else {
                        action = .dropAndMove(droppedPiece.id,
                                              sourceIndex: droppedPiece.index!,
                                              dragTranslation: dragTranslation,
                                              newIndex: targetingIndex)
                    }
                }
        }
        
        self.execute(action)
    }
}

private extension AppModel {
    func dragTargetingIndex(dragTranslation: SIMD3<Float>, sourceIndex: Index) -> Index {
        var closestIndex = Index(0, 0)
        let bodyPosition = sourceIndex.position + dragTranslation
        for column in 0..<8 {
            for row in 0..<8 {
                let index = Index(row, column)
                if distance(bodyPosition, closestIndex.position)
                    > distance(bodyPosition, index.position) {
                    closestIndex = index
                }
            }
        }
        return closestIndex
    }
}
