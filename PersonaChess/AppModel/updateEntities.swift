import RealityKit

extension AppModel {
    func updateEntities() {
        self.addOrRemovePieceEntities()
        
        self.setPawnPromotion()
        
        self.entities.updateHoverEffect(disabled: self.sharedState.pieces.isDragging)
        
        self.updatePickedPieceInputability()
        
        self.setPiecesPositionWithoutAnimation()
        
        self.entities.updateWithAnimation(self.sharedState.pieces.currentAction)
    }
}

private extension AppModel {
    private func addOrRemovePieceEntities() {
        for piece in Piece.allCases {
            if let index = self.sharedState.pieces.indices[piece] {
                self.entities.add(piece,
                                  index: index)
            } else {
                if let capturedPieceInProgress = self.sharedState.pieces.capturedPieceInProgress {
                    self.entities.add(capturedPieceInProgress.piece,
                                      index: capturedPieceInProgress.index)
                } else {
                    self.entities.remove(piece)
                }
            }
        }
    }
    private func setPawnPromotion() {
        for piece in self.sharedState.pieces.list {
            let promotion = self.sharedState.pieces.promotions[piece]
            self.entities.applyPiecePromotion(piece, promotion)
        }
    }
    private func updatePickedPieceInputability() {
        for piece in self.sharedState.pieces.list {
            let isPicking = (self.sharedState.pieces.pickingPiece == piece)
            self.entities.updatePickedPieceInputability(piece,
                                                        isEnabled: !isPicking)
        }
    }
    private func setPiecesPositionWithoutAnimation() {
        for piece in self.sharedState.pieces.list {
            guard !self.sharedState.pieces.hasAnimation(piece) else { continue }
            let index = self.sharedState.pieces.indices[piece]!
            self.entities.setPositionWithoutAnimation(piece, index)
        }
    }
}

//extension AppModel {
//    func updateEntities_old() {
//        for pieceEntity in self.entities.root.children.filter({ $0.components.has(Piece.self) }) {
//            let exState: Piece = pieceEntity.components[Piece.self]!
//            let newState: Piece = self.sharedState.pieces[exState.id]
//            guard exState != newState else { continue }
//            if newState.removed {
//                pieceEntity.components[Piece.self] = newState
//                //Fade out by PieceOpacitySystem
//            } else {
//                if newState.dragging {
//                    self.entities.applyDraggingPiecePosition(pieceEntity, newState)
//                } else if exState.dragging {
//                    Task { @MainActor in
//                        self.movingPieces.append(exState.id)
//                        await self.entities.applyPieceDrop(pieceEntity, newState)
//                        if exState.index != newState.index {
//                            self.soundFeedback.put(pieceEntity, self.floorMode)
//                        }
//                        self.movingPieces.removeAll { $0 == exState.id }
//                    }
//                } else {
//                    Task { @MainActor in
//                        self.entities.disablePieceHoverEffect()
//                        self.movingPieces.append(exState.id)
//                        if exState.index != newState.index {
//                            await self.entities.applyPieceMove(pieceEntity, exState, newState)
//                            self.soundFeedback.put(pieceEntity, self.floorMode)
//                        } else {
//                            if exState.picked != newState.picked {
//                                await self.entities.applyPiecePickingState(pieceEntity, exState, newState)
//                            }
//                        }
//                        self.movingPieces.removeAll { $0 == exState.id }
//                        self.entities.applyPiecePromotion(pieceEntity, newState)
//                        pieceEntity.components[Piece.self] = newState
//                        self.entities.activatePieceHoverEffect()
//                        Entities.updatePickingInputtablity(pieceEntity)
//                    }
//                }
//            }
//        }
//    }
//}
