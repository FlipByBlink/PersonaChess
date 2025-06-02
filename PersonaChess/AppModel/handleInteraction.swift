import simd

extension AppModel {
    func handle(_ interaction: Interaction) {
        let action: Action
        
        switch interaction {
            case .tapPiece(let tappedPiece):
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
            case .drag(let dragState):
                if dragState.count == 0 {
                    action = .beginDrag(dragState)
                } else {
                    self.executeDrag(dragState)
                    return
                }
            case .drop(let dragState):
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
        
        self.execute(action)
    }
}
