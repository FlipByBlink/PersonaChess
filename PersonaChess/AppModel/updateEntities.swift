extension AppModel {
    func updateEntities() {
        for pieceEntity in self.entities.root.children.filter({ $0.components.has(Piece.self) }) {
            let exPiece: Piece = pieceEntity.components[Piece.self]!
            let newPiece: Piece = self.sharedState.pieces[exPiece.id]
            guard exPiece != newPiece else { continue }
            if newPiece.removed {
                pieceEntity.components[Piece.self] = newPiece
                //Fade out by PieceOpacitySystem
            } else {
                if newPiece.dragging {
                    self.entities.applyDraggingPiecePosition(pieceEntity, newPiece)
                } else if exPiece.dragging {
                    Task { @MainActor in
                        self.movingPieces.append(exPiece.id)
                        await self.entities.applyPieceDrop(pieceEntity, newPiece)
                        if exPiece.index != newPiece.index {
                            self.soundFeedback.put(pieceEntity, self.floorMode)
                        }
                        self.movingPieces.removeAll { $0 == exPiece.id }
                    }
                } else {
                    Task { @MainActor in
                        self.entities.disablePieceHoverEffect()
                        self.movingPieces.append(exPiece.id)
                        if exPiece.index != newPiece.index {
                            await self.entities.applyPieceMove(pieceEntity, exPiece, newPiece)
                            self.soundFeedback.put(pieceEntity, self.floorMode)
                        } else {
                            if exPiece.picked != newPiece.picked {
                                await self.entities.applyPiecePickingState(pieceEntity, exPiece, newPiece)
                            }
                        }
                        self.movingPieces.removeAll { $0 == exPiece.id }
                        self.entities.applyPiecePromotion(pieceEntity, newPiece)
                        pieceEntity.components[Piece.self] = newPiece
                        self.entities.activatePieceHoverEffect()
                        Entities.updateInputtablity(pieceEntity)
                    }
                }
            }
        }
    }
}
