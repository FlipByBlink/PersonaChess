import simd

extension AppModel {
    func handle(_ interaction: Interaction) {
        let action: Action
        
        switch interaction {
            case .tapPiece(let tappedPiece):
                guard let tappedPieceIndex = self.sharedState.pieces.indices[tappedPiece] else {
                    assertionFailure(); return
                }
                guard !self.sharedState.pieces.isPicking else {
                    assertionFailure(); return
                }
                action = .tapPieceAndPick(tappedPiece, tappedPieceIndex)
            case .tapSquare(let tappedIndex):
                guard let pickedPiece = self.sharedState.pieces.pickingPiece,
                      let pickedPieceIndex = self.sharedState.pieces.indices[pickedPiece] else {
                    assertionFailure(); return
                }
                if tappedIndex == pickedPieceIndex {
                    action = .tapSquareAndUnpick(pickedPiece,
                                                 pickedPieceIndex)
                } else {
                    if let targetedPiece = self.sharedState.pieces.piece(tappedIndex) {
                        if targetedPiece.side == pickedPiece.side {
                            action = .tapSquareAndChangePickingPiece(
                                exPickedPiece: pickedPiece,
                                exPickedPieceIndex: pickedPieceIndex,
                                newPickedPiece: targetedPiece,
                                newPickedPieceIndex: tappedIndex
                            )
                        } else {
                            action = .tapSquareAndMoveAndCapture(
                                pickedPiece: pickedPiece,
                                pickedPieceIndex: pickedPieceIndex,
                                capturedPiece: targetedPiece,
                                capturedPieceIndex: tappedIndex
                            )
                        }
                    } else {
                        action = .tapSquareAndMove(pickedPiece,
                                                   exIndex: pickedPieceIndex,
                                                   newIndex: tappedIndex)
                    }
                }
            case .drag(let dragState):
                if dragState.isFirst {
                    action = .beginDrag(dragState)
                } else {
                    self.executeDrag(dragState)
                    return
                }
            case .drop(let dragState):
                if dragState.shouldRemove {
                    action = .remove(dragState.piece)
                } else {
                    let targetingIndex = Index.calculateFromDrag(dragState)
                    if dragState.sourceIndex == targetingIndex {
                        action = .dropAndBack(dragState)
                    } else {
                        if let targetingIndexPiece = self.sharedState.pieces.piece(targetingIndex) {
                            if targetingIndexPiece.side == dragState.piece.side {
                                action = .dropAndBack(dragState)
                            } else {
                                action = .dropAndMoveAndCapture(dragState,
                                                                capturedPiece: targetingIndexPiece,
                                                                capturedPieceIndex: targetingIndex)
                            }
                        } else {
                            action = .dropAndMove(dragState,
                                                  newIndex: targetingIndex)
                        }
                    }
                }
        }
        
        self.execute(action)
    }
}
