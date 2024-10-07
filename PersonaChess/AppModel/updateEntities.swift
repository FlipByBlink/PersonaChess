import RealityKit

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
