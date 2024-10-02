import RealityKit

extension AppModel {
    func updateEntities() {
        for pieceID in Piece.ID.allCases {
            if self.sharedState.pieces.isCapturedPieceInProgress(pieceID) {
                let capturedPieceInProgressEntity = self.entities.piece(pieceID)
                self.entities.root.addChild(capturedPieceInProgressEntity)
                capturedPieceInProgressEntity.components[OpacityComponent.self]?.opacity = 1.0
            } else {
                let piece = self.sharedState.pieces[pieceID]
                let pieceEntity = self.entities.piece(pieceID)
                if piece.isActive {
                    self.entities.root.addChild(pieceEntity)
                    pieceEntity.components[OpacityComponent.self]?.opacity = 1.0
                } else {
                    pieceEntity.removeFromParent()
                }
            }
        }
        
        for piece in self.sharedState.pieces.withNoAnimation {
            if let index = piece.index {
                self.entities.piece(piece.id).setPosition(index.position,
                                                          relativeTo: self.entities.root)
                self.entities.pieceBody(piece.id).setPosition(.zero,
                                                              relativeTo: self.entities.piece(piece.id))
            }
        }
        
        switch self.sharedState.pieces.currentAction {
            case .tapPieceAndPick(let id, let index):
                self.entities.piece(id).setPosition(index.position,
                                                    relativeTo: self.entities.root)
                self.entities.pieceBody(id).playAnimation(
                    try! .makeActionAnimation(
                        for: FromToByAction(to: Transform(translation: [0, Size.Meter.pickedOffset, 0]),
                                            mode: .parent,
                                            timing: .easeInOut),
                        duration: 0.6,
                        bindTarget: .transform
                    )
                )
            case .tapPieceAndChangePickingPiece(let exPickedPieceID,
                                                let exPickedPieceIndex,
                                                let newPickedPieceID,
                                                let newPickedPieceIndex):
                self.entities.piece(exPickedPieceID).setPosition(exPickedPieceIndex.position,
                                                                 relativeTo: self.entities.root)
                self.entities.piece(newPickedPieceID).setPosition(newPickedPieceIndex.position,
                                                                  relativeTo: self.entities.root)
                self.entities.pieceBody(newPickedPieceID).playAnimation(
                    try! .makeActionAnimation(
                        for: FromToByAction(to: Transform(translation: [0, Size.Meter.pickedOffset, 0]),
                                            mode: .parent,
                                            timing: .easeInOut),
                        duration: 0.6,
                        bindTarget: .transform
                    )
                )
                self.entities.pieceBody(exPickedPieceID).playAnimation(
                    try! .makeActionAnimation(
                        for: FromToByAction(to: .identity,
                                            mode: .parent,
                                            timing: .easeInOut),
                        duration: 0.6,
                        bindTarget: .transform
                    )
                )
            case .tapPieceAndMoveAndCapture(let pickedPieceID,
                                            let pickedPieceIndex,
                                            let capturedPieceID,
                                            let capturedPieceIndex):
                let pickedPieceEntity = self.entities.piece(pickedPieceID)
                pickedPieceEntity.setPosition(pickedPieceIndex.position,
                                              relativeTo: self.entities.root)
                pickedPieceEntity.setPosition([0, Size.Meter.pickedOffset, 0],
                                              relativeTo: pickedPieceEntity)
                self.entities.piece(capturedPieceID).setPosition(capturedPieceIndex.position,
                                                                 relativeTo: self.entities.root)
                let slideDuration = 1.0
                self.entities.piece(pickedPieceID).playAnimation(
                    try! .makeActionAnimation(
                        for: FromToByAction(from: Transform(translation: pickedPieceIndex.position),
                                            to: Transform(translation: capturedPieceIndex.position),
                                            mode: .parent,
                                            timing: .easeInOut),
                        duration: slideDuration,
                        bindTarget: .transform
                    )
                )
                self.entities.pieceBody(pickedPieceID).playAnimation(
                    try! .makeActionAnimation(
                        for: FromToByAction(to: .identity,
                                            mode: .parent,
                                            timing: .easeInOut),
                        duration: 0.6,
                        bindTarget: .transform,
                        delay: slideDuration
                    )
                )
                let fadeOutDuration = 0.6
                self.entities.piece(capturedPieceID).playAnimation(
                    try! .makeActionAnimation(
                        for: FromToByAction<Float>(to: 0.0),
                        duration: fadeOutDuration,
                        bindTarget: .opacity,
                        delay: slideDuration
                    )
                )
                Task {
                    try? await Task.sleep(for: .seconds(slideDuration + fadeOutDuration))
                    self.entities.piece(capturedPieceID).removeFromParent()
                }
            case .tapSquareAndUnpick(let id, _):
                self.entities.pieceBody(id).playAnimation(
                    try! .makeActionAnimation(
                        for: FromToByAction(from: Transform(translation: [0, Size.Meter.pickedOffset, 0]),
                                            to: .identity,
                                            mode: .parent,
                                            timing: .easeInOut,
                                            isAdditive: true),
                        duration: 0.7,
                        bindTarget: .transform
                    )
                )
            case .tapSquareAndMove(let id, let exIndex, let newIndex):
                self.entities.piece(id).playAnimation(
                    try! .makeActionAnimation(
                        for: FromToByAction(from: Transform(translation: exIndex.position),
                                            to: Transform(translation: newIndex.position),
                                            mode: .parent,
                                            timing: .easeInOut,
                                            isAdditive: true),
                        duration: 1,
                        bindTarget: .transform
                    )
                )
                self.entities.pieceBody(id).playAnimation(
                    try! .makeActionAnimation(
                        for: FromToByAction(from: Transform(translation: [0, Size.Meter.pickedOffset, 0]),
                                            to: .identity,
                                            mode: .parent,
                                            timing: .easeInOut,
                                            isAdditive: true),
                        duration: 0.7,
                        bindTarget: .transform,
                        delay: 1
                    )
                )
            case .drag(let id, let sourceIndex, let dragTranslation):
                let draggedPieceBodyPosition = {
                    var resultTranslation = dragTranslation
                    if dragTranslation.y < 0 {
                        resultTranslation.y = 0
                    }
                    return sourceIndex.position + resultTranslation
                }()
                self.entities.pieceBody(id).position.y = draggedPieceBodyPosition.y
                self.entities.piece(id).setPosition(.init(x: draggedPieceBodyPosition.x,
                                                          y: 0,
                                                          z: draggedPieceBodyPosition.z),
                                                    relativeTo: self.entities.root)
            case .dropAndBack(let id, let sourceIndex, let dragTranslation):
                let draggedPieceBodyPosition = {
                    var resultTranslation = dragTranslation
                    if dragTranslation.y < 0 {
                        resultTranslation.y = 0
                    }
                    return sourceIndex.position + resultTranslation
                }()
                self.entities.pieceBody(id).position.y = draggedPieceBodyPosition.y
                let draggedPiecePosition: SIMD3<Float> = .init(x: draggedPieceBodyPosition.x,
                                                               y: 0,
                                                               z: draggedPieceBodyPosition.z)
                self.entities.piece(id).setPosition(draggedPiecePosition,
                                                    relativeTo: self.entities.root)
                let duration = 0.7
                self.entities.pieceBody(id).playAnimation(
                    try! .makeActionAnimation(
                        for: FromToByAction(from: Transform(translation: [0, draggedPieceBodyPosition.y, 0]),
                                            to: .identity,
                                            mode: .parent,
                                            timing: .easeInOut,
                                            isAdditive: true),
                        duration: duration,
                        bindTarget: .transform
                    )
                )
                self.entities.piece(id).playAnimation(
                    try! .makeActionAnimation(
                        for: FromToByAction(from: Transform(translation: draggedPiecePosition),
                                            to: Transform(translation: sourceIndex.position),
                                            mode: .parent,
                                            timing: .easeInOut,
                                            isAdditive: true),
                        duration: duration,
                        bindTarget: .transform
                    )
                )
            case .dropAndMove(let id,
                              let sourceIndex,
                              let dragTranslation,
                              let newIndex):
                let draggedPieceBodyPosition = {
                    var resultTranslation = dragTranslation
                    if dragTranslation.y < 0 {
                        resultTranslation.y = 0
                    }
                    return sourceIndex.position + resultTranslation
                }()
                self.entities.pieceBody(id).position.y = draggedPieceBodyPosition.y
                let draggedPiecePosition: SIMD3<Float> = .init(x: draggedPieceBodyPosition.x,
                                                               y: 0,
                                                               z: draggedPieceBodyPosition.z)
                self.entities.piece(id).setPosition(draggedPiecePosition,
                                                    relativeTo: self.entities.root)
                let duration = 0.7
                self.entities.pieceBody(id).playAnimation(
                    try! .makeActionAnimation(
                        for: FromToByAction(from: Transform(translation: [0, draggedPieceBodyPosition.y, 0]),
                                            to: .identity,
                                            mode: .parent,
                                            timing: .easeInOut,
                                            isAdditive: true),
                        duration: duration,
                        bindTarget: .transform
                    )
                )
                self.entities.piece(id).playAnimation(
                    try! .makeActionAnimation(
                        for: FromToByAction(from: Transform(translation: draggedPiecePosition),
                                            to: Transform(translation: newIndex.position),
                                            mode: .parent,
                                            timing: .easeInOut,
                                            isAdditive: true),
                        duration: duration,
                        bindTarget: .transform
                    )
                )
            case .dropAndMoveAndCapture(let id,
                                        let sourceIndex,
                                        let dragTranslation,
                                        let capturedPieceID,
                                        let capturedPieceIndex):
                let draggedPieceBodyPosition = {
                    var resultTranslation = dragTranslation
                    if dragTranslation.y < 0 {
                        resultTranslation.y = 0
                    }
                    return sourceIndex.position + resultTranslation
                }()
                self.entities.pieceBody(id).position.y = draggedPieceBodyPosition.y
                let draggedPiecePosition: SIMD3<Float> = .init(x: draggedPieceBodyPosition.x,
                                                               y: 0,
                                                               z: draggedPieceBodyPosition.z)
                self.entities.piece(id).setPosition(draggedPiecePosition,
                                                    relativeTo: self.entities.root)
                let duration = 0.7
                self.entities.pieceBody(id).playAnimation(
                    try! .makeActionAnimation(
                        for: FromToByAction(from: Transform(translation: [0, draggedPieceBodyPosition.y, 0]),
                                            to: .identity,
                                            mode: .parent,
                                            timing: .easeInOut,
                                            isAdditive: true),
                        duration: duration,
                        bindTarget: .transform
                    )
                )
                self.entities.piece(id).playAnimation(
                    try! .makeActionAnimation(
                        for: FromToByAction(from: Transform(translation: draggedPiecePosition),
                                            to: Transform(translation: capturedPieceIndex.position),
                                            mode: .parent,
                                            timing: .easeInOut,
                                            isAdditive: true),
                        duration: duration,
                        bindTarget: .transform
                    )
                )
                self.entities.piece(capturedPieceID).playAnimation(
                    try! .makeActionAnimation(
                        for: FromToByAction<Float>(to: 0.0),
                        duration: duration,
                        bindTarget: .opacity
                    )
                )
                Task {
                    try? await Task.sleep(for: .seconds(duration))
                    self.entities.piece(capturedPieceID).removeFromParent()
                }
            case .undo, .reset, .none:
                break
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
