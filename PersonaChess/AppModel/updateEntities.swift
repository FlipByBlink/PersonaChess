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
        
        //MARK: Set no-animation-piece position
        for piece in self.sharedState.pieces.list {
            guard !self.sharedState.pieces.hasAnimation(piece) else { continue }
            let index = self.sharedState.pieces.indices[piece]!
            self.entities.piece(piece)?.setPosition(index.position,
                                                    relativeTo: self.entities.root)
            self.entities.pieceBody(piece)?.setPosition(.zero,
                                                        relativeTo: self.entities.piece(piece))
        }
        
        //MARK: Apply action
        switch self.sharedState.pieces.currentAction {
            case .tapPieceAndPick(let piece, let index):
                self.entities.piece(piece)!.setPosition(index.position,
                                                        relativeTo: self.entities.root)
                self.entities.pieceBody(piece)!.playAnimation(
                    try! .makeActionAnimation(
                        for: FromToByAction(to: Transform(translation: [0, Size.Meter.pickedOffset, 0]),
                                            mode: .parent,
                                            timing: .easeInOut),
                        duration: 0.6,
                        bindTarget: .transform
                    )
                )
            case .tapPieceAndChangePickingPiece(let exPickedPiece,
                                                let exPickedPieceIndex,
                                                let newPickedPiece,
                                                let newPickedPieceIndex):
                self.entities.piece(exPickedPiece)!.setPosition(exPickedPieceIndex.position,
                                                                relativeTo: self.entities.root)
                self.entities.piece(newPickedPiece)!.setPosition(newPickedPieceIndex.position,
                                                                 relativeTo: self.entities.root)
                self.entities.pieceBody(newPickedPiece)!.playAnimation(
                    try! .makeActionAnimation(
                        for: FromToByAction(to: Transform(translation: [0, Size.Meter.pickedOffset, 0]),
                                            mode: .parent,
                                            timing: .easeInOut),
                        duration: 0.6,
                        bindTarget: .transform
                    )
                )
                self.entities.pieceBody(exPickedPiece)!.playAnimation(
                    try! .makeActionAnimation(
                        for: FromToByAction(to: .identity,
                                            mode: .parent,
                                            timing: .easeInOut),
                        duration: 0.6,
                        bindTarget: .transform
                    )
                )
            case .tapPieceAndMoveAndCapture(let pickedPiece,
                                            let pickedPieceIndex,
                                            let capturedPiece,
                                            let capturedPieceIndex):
                let pickedPieceEntity = self.entities.piece(pickedPiece)!
                pickedPieceEntity.setPosition(pickedPieceIndex.position,
                                              relativeTo: self.entities.root)
                pickedPieceEntity.setPosition([0, Size.Meter.pickedOffset, 0],
                                              relativeTo: pickedPieceEntity)
                self.entities.piece(capturedPiece)!.setPosition(capturedPieceIndex.position,
                                                                relativeTo: self.entities.root)
                let slideDuration = 1.0
                self.entities.piece(pickedPiece)!.playAnimation(
                    try! .makeActionAnimation(
                        for: FromToByAction(from: Transform(translation: pickedPieceIndex.position),
                                            to: Transform(translation: capturedPieceIndex.position),
                                            mode: .parent,
                                            timing: .easeInOut),
                        duration: slideDuration,
                        bindTarget: .transform
                    )
                )
                self.entities.pieceBody(pickedPiece)!.playAnimation(
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
                self.entities.piece(capturedPiece)!.playAnimation(
                    try! .makeActionAnimation(
                        for: FromToByAction<Float>(to: 0.0),
                        duration: fadeOutDuration,
                        bindTarget: .opacity,
                        delay: slideDuration
                    )
                )
                Task {
                    try? await Task.sleep(for: .seconds(slideDuration + fadeOutDuration))
                    self.entities.remove(capturedPiece)
                }
            case .tapSquareAndUnpick(let piece, _):
                self.entities.pieceBody(piece)!.playAnimation(
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
            case .tapSquareAndMove(let piece, let exIndex, let newIndex):
                self.entities.piece(piece)!.playAnimation(
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
                self.entities.pieceBody(piece)!.playAnimation(
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
            case .drag(let piece, let sourceIndex, let dragTranslation):
                let draggedPieceBodyPosition = {
                    var resultTranslation = dragTranslation
                    if dragTranslation.y < 0 {
                        resultTranslation.y = 0
                    }
                    return sourceIndex.position + resultTranslation
                }()
                self.entities.pieceBody(piece)!.position.y = draggedPieceBodyPosition.y
                self.entities.piece(piece)!.setPosition(.init(x: draggedPieceBodyPosition.x,
                                                              y: 0,
                                                              z: draggedPieceBodyPosition.z),
                                                        relativeTo: self.entities.root)
            case .dropAndBack(let piece, let sourceIndex, let dragTranslation):
                let draggedPieceBodyPosition = {
                    var resultTranslation = dragTranslation
                    if dragTranslation.y < 0 {
                        resultTranslation.y = 0
                    }
                    return sourceIndex.position + resultTranslation
                }()
                self.entities.pieceBody(piece)!.position.y = draggedPieceBodyPosition.y
                let draggedPiecePosition: SIMD3<Float> = .init(x: draggedPieceBodyPosition.x,
                                                               y: 0,
                                                               z: draggedPieceBodyPosition.z)
                self.entities.piece(piece)!.setPosition(draggedPiecePosition,
                                                        relativeTo: self.entities.root)
                let duration = 0.7
                self.entities.pieceBody(piece)!.playAnimation(
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
                self.entities.piece(piece)!.playAnimation(
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
            case .dropAndMove(let piece,
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
                self.entities.pieceBody(piece)!.position.y = draggedPieceBodyPosition.y
                let draggedPiecePosition: SIMD3<Float> = .init(x: draggedPieceBodyPosition.x,
                                                               y: 0,
                                                               z: draggedPieceBodyPosition.z)
                self.entities.piece(piece)!.setPosition(draggedPiecePosition,
                                                        relativeTo: self.entities.root)
                let duration = 0.7
                self.entities.pieceBody(piece)!.playAnimation(
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
                self.entities.piece(piece)!.playAnimation(
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
            case .dropAndMoveAndCapture(let piece,
                                        let sourceIndex,
                                        let dragTranslation,
                                        let capturedPiece,
                                        let capturedPieceIndex):
                let draggedPieceBodyPosition = {
                    var resultTranslation = dragTranslation
                    if dragTranslation.y < 0 {
                        resultTranslation.y = 0
                    }
                    return sourceIndex.position + resultTranslation
                }()
                self.entities.pieceBody(piece)!.position.y = draggedPieceBodyPosition.y
                let draggedPiecePosition: SIMD3<Float> = .init(x: draggedPieceBodyPosition.x,
                                                               y: 0,
                                                               z: draggedPieceBodyPosition.z)
                self.entities.piece(piece)!.setPosition(draggedPiecePosition,
                                                        relativeTo: self.entities.root)
                let duration = 0.7
                self.entities.pieceBody(piece)!.playAnimation(
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
                self.entities.piece(piece)!.playAnimation(
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
                self.entities.piece(capturedPiece)!.playAnimation(
                    try! .makeActionAnimation(
                        for: FromToByAction<Float>(to: 0.0),
                        duration: duration,
                        bindTarget: .opacity
                    )
                )
                Task {
                    try? await Task.sleep(for: .seconds(duration))
                    self.entities.remove(capturedPiece)
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
