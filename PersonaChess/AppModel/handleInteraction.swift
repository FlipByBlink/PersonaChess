import simd

extension AppModel {
    func handle(_ interaction: Interaction) {
        let action: Action
        
        switch interaction {
            case .tapPiece(let tappedPieceBodyEntity):
                let tappedPiece = tappedPieceBodyEntity.parent!.components[Piece.self]!
                guard let tappedPieceIndex = self.sharedState.pieces.indices[tappedPiece] else {
                    assertionFailure(); return //TODO: ここを通る場合がある。要確認。
                }
                if self.sharedState.pieces.isPicking {
                    guard let pickingPiece = self.sharedState.pieces.pickingPiece,
                          let pickingPieceIndex = self.sharedState.pieces.indices[pickingPiece] else {
                        assertionFailure(); return
                    }
                    if tappedPiece.side == pickingPiece.side {
                        action = .tapPieceAndChangePickingPiece(exPickedPiece: pickingPiece,
                                                                exPickedPieceIndex: pickingPieceIndex,
                                                                newPickedPiece: tappedPiece,
                                                                newPickedPieceIndex: tappedPieceIndex)
                    } else {
                        action = .tapPieceAndMoveAndCapture(pickedPiece: pickingPiece,
                                                            pickedPieceIndex: pickingPieceIndex,
                                                            capturedPiece: tappedPiece,
                                                            capturedPieceIndex: tappedPieceIndex)
                    }
                } else {
                    action = .tapPieceAndPick(tappedPiece, tappedPieceIndex)
                }
            case .tapSquare(let tappedIndex):
                guard let pickedPiece = self.sharedState.pieces.pickingPiece,
                      let pickedPieceIndex = self.sharedState.pieces.indices[pickedPiece] else {
                    assertionFailure(); return
                }
                if tappedIndex == pickedPieceIndex {
                    action = .tapSquareAndUnpick(pickedPiece,
                                                 pickedPieceIndex)
                } else {
                    action = .tapSquareAndMove(pickedPiece,
                                               exIndex: pickedPieceIndex,
                                               newIndex: tappedIndex)
                }
            case .drag(let draggedPiece, let dragTranslation):
                guard let draggedPieceIndex = self.sharedState.pieces.indices[draggedPiece] else {
                    assertionFailure(); return
                }
                action = .drag(draggedPiece,
                               sourceIndex: draggedPieceIndex,
                               dragTranslation: dragTranslation,
                               isDragStarted: !self.isDragging)
                self.isDragging = true
            case .drop(let droppedPiece, let dragTranslation):
                guard let droppedPieceIndex = self.sharedState.pieces.indices[droppedPiece] else {
                    assertionFailure(); return
                }
                let targetingIndex = Index.calculateFromDrag(dragTranslation: dragTranslation,
                                                             sourceIndex: droppedPieceIndex)
                if droppedPieceIndex == targetingIndex {
                    action = .dropAndBack(droppedPiece,
                                          sourceIndex: droppedPieceIndex,
                                          dragTranslation: dragTranslation)
                } else {
                    if let targetingIndexPiece = self.sharedState.pieces.piece(targetingIndex) {
                        if targetingIndexPiece.side == droppedPiece.side {
                            action = .dropAndBack(droppedPiece,
                                                  sourceIndex: droppedPieceIndex,
                                                  dragTranslation: dragTranslation)
                        } else {
                            action = .dropAndMoveAndCapture(droppedPiece,
                                                            sourceIndex: droppedPieceIndex,
                                                            dragTranslation: dragTranslation,
                                                            capturedPiece: targetingIndexPiece,
                                                            capturedPieceIndex: targetingIndex)
                        }
                    } else {
                        action = .dropAndMove(droppedPiece,
                                              sourceIndex: droppedPieceIndex,
                                              dragTranslation: dragTranslation,
                                              newIndex: targetingIndex)
                    }
                }
                self.isDragging = false
        }
        
        self.execute(action)
    }
}
