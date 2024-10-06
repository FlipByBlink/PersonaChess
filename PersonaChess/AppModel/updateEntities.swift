import RealityKit

extension AppModel {
    func updateEntities() {
        //MARK: Add or Remove entity
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
        
        //MARK: Set promotion
        for piece in self.sharedState.pieces.list {
            let promotion = self.sharedState.pieces.promotions[piece]
            self.entities.applyPiecePromotion(piece, promotion)
        }
        
        //MARK: Set position without animation
        for piece in self.sharedState.pieces.list {
            guard !self.sharedState.pieces.hasAnimation(piece) else { continue }
            let index = self.sharedState.pieces.indices[piece]!
            self.entities.setPositionWithoutAnimation(piece, index)
        }
        
        //MARK: Apply action with animation
        self.entities.updateWithAnimation(self.sharedState.pieces.currentAction)
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
