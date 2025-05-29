import RealityKit
import Foundation

@MainActor
class Entities {
    let root = Entity()
}

extension Entities {
    func update(_ pieces: Pieces) {
        self.stopAllAnimations()
        
        self.addOrRemovePieceEntities(pieces)
        
        self.setPawnPromotion(pieces)
        
        self.updateHoverEffect(disabled: pieces.isDragging)
        
        self.disableInputDuringAnimation(pieces)
        
        self.updatePieceOpacityDuringDragging(pieces)
        
        self.setPiecesPositionWithoutAnimation(pieces)
        
        guard let currentAction = pieces.currentAction else { return }
        
        self.setPositionBeforeAnimation(currentAction)
        
        self.updateWithAnimation(currentAction)
        
        self.playResetSoundFromBoard(currentAction)
    }
    
    func dragUpdate(_ pieces: Pieces,
                    _ dragAction: Action) {
        self.stopAllAnimations()
        
        self.updateHoverEffect(disabled: true)
        
        self.updatePieceOpacityDuringDragging(pieces)
        
        self.setPositionBeforeAnimation(dragAction)
        
        self.updateWithAnimation(dragAction)
    }
}

private extension Entities {
    private func pieceEntity(_ piece: Piece) -> Entity? {
        self.root
            .children
            .filter { $0.components.has(Piece.self) }
            .first { $0.components[Piece.self]! == piece }
    }
    private func pieceBodyEntity(_ piece: Piece) -> Entity? {
        self.pieceEntity(piece)?.findEntity(named: "body")
    }
    private func add(_ piece: Piece, index: Index) {
        if self.pieceEntity(piece) == nil {
            self.root.addChild(PieceEntity.load(piece, index))
        }
    }
    private func remove(_ piece: Piece, delay: TimeInterval? = nil) {
        Task {
            if let delay { try? await Task.sleep(for: .seconds(delay)) }
            self.pieceEntity(piece)?.removeFromParent()
        }
    }
    private func addOrRemovePieceEntities(_ pieces: Pieces) {
        for piece in Piece.allCases {
            if let index = pieces.indices[piece] {
                self.add(piece, index: index)
            } else {
                if let capturedPieceInProgress = pieces.capturedPieceInProgress {
                    self.add(capturedPieceInProgress.piece,
                             index: capturedPieceInProgress.index)
                } else {
                    self.remove(piece)
                }
            }
        }
    }
    private func stopAllAnimations() {
        self.root
            .children
            .filter { $0.components.has(Piece.self) }
            .forEach {
                $0.stopAllAnimations(recursive: false)
                $0.findEntity(named: "body")!.stopAllAnimations()
            }
    }
    private func setPawnPromotion(_ pieces: Pieces) {
        for piece in pieces.all {
            guard piece.chessmen.role == .pawn,
                  let pieceEntity = self.pieceEntity(piece) else {
                continue
            }
            if pieces.promotions[piece] == true {
                PieceEntity.addPromotionMarkEntity(pieceEntity, piece.side)
            } else {
                PieceEntity.removePromotionMarkEntity(pieceEntity)
            }
        }
    }
    private func updateHoverEffect(disabled: Bool) {
        self.root
            .children
            .filter { $0.components.has(Piece.self) }
            .map { $0.findEntity(named: "body")! }
            .forEach {
                if disabled {
                    $0.components.remove(HoverEffectComponent.self)
                } else {
                    $0.components.set(HoverEffectComponent())
                }
            }
    }
    private func setPiecesPositionWithoutAnimation(_ pieces: Pieces) {
        for piece in pieces.all {
            guard !pieces.hasAnimation(piece) else { continue }
            let index = pieces.indices[piece]!
            self.pieceEntity(piece)?.setPosition(index.position,
                                                 relativeTo: self.root)
            self.pieceBodyEntity(piece)?.setPosition(.zero,
                                                     relativeTo: self.pieceEntity(piece))
        }
    }
    private func setPositionBeforeAnimation(_ action: Action) {
        switch action {
            case .tapPieceAndPick(let piece, let index):
                self.setPosition(piece: piece,
                                 index: index,
                                 picked: false)
            case .tapPieceAndMoveAndCapture(let pickedPiece,
                                            let pickedPieceIndex,
                                            let capturedPiece,
                                            let capturedPieceIndex):
                self.setPosition(piece: pickedPiece,
                                 index: pickedPieceIndex,
                                 picked: true)
                self.setPosition(piece: capturedPiece,
                                 index: capturedPieceIndex,
                                 picked: false)
            case .tapSquareAndUnpick(let piece, let index):
                self.setPosition(piece: piece,
                                 index: index,
                                 picked: true)
            case .tapSquareAndMove(let piece, let exIndex, _):
                self.setPosition(piece: piece,
                                 index: exIndex,
                                 picked: true)
            case .drag(let piece, _, _, _),
                    .dropAndBack(let piece, _, _),
                    .dropAndMove(let piece, _, _, _),
                    .dropAndMoveAndCapture(let piece, _, _, _, _):
                self.setPosition(piece: piece,
                                 dragAction: action)
            default:
                break
        }
    }
    private func updateWithAnimation(_ action: Action) {
        switch action {
            case .tapPieceAndPick(let piece, let index):
                self.moveUp(piece: piece,
                            index: index)
                self.playSound(piece,
                               kind: .select)
            case .tapPieceAndChangePickingPiece(let exPickedPiece,
                                                let exPickedPieceIndex,
                                                let newPickedPiece,
                                                let newPickedPieceIndex):
                self.moveDown(piece: exPickedPiece,
                              index: exPickedPieceIndex)
                self.moveUp(piece: newPickedPiece,
                            index: newPickedPieceIndex)
                self.playSound(newPickedPiece,
                               kind: .select)
            case .tapPieceAndMoveAndCapture(let pickedPiece,
                                            let pickedPieceIndex,
                                            let capturedPiece,
                                            let capturedPieceIndex):
                self.moveHorizontally(piece: pickedPiece,
                                      exIndex: pickedPieceIndex,
                                      newIndex: capturedPieceIndex)
                self.moveDown(piece: pickedPiece,
                              index: capturedPieceIndex,
                              delay: PieceAnimation.horizontal.duration)
                self.playSound(pickedPiece,
                               kind: .put,
                               delay: PieceAnimation.wholeDuration(action))
                self.fadeout(piece: capturedPiece,
                             delay: PieceAnimation.horizontal.duration)
                self.remove(capturedPiece,
                            delay: PieceAnimation.wholeDuration(action))
            case .tapSquareAndUnpick(let piece, let index):
                self.moveDown(piece: piece,
                              index: index)
            case .tapSquareAndMove(let piece, let exIndex, let newIndex):
                self.moveHorizontally(piece: piece,
                                      exIndex: exIndex,
                                      newIndex: newIndex)
                self.moveDown(piece: piece,
                              index: newIndex,
                              delay: PieceAnimation.horizontal.duration)
                self.playSound(piece,
                               kind: .put,
                               delay: PieceAnimation.wholeDuration(action))
            case .drag(let piece, _, _, let isDragStarted):
                self.setPosition(piece: piece,
                                 dragAction: action)
                if isDragStarted {
                    self.playSound(piece,
                                   kind: .select)
                }
            case .dropAndBack(let piece, let sourceIndex, _):
                self.drop(piece: piece,
                          index: sourceIndex,
                          dropAction: action)
            case .dropAndMove(let piece, _, _, let newIndex):
                self.drop(piece: piece,
                          index: newIndex,
                          dropAction: action)
                self.playSound(piece,
                               kind: .put,
                               delay: PieceAnimation.drop.duration)
            case .dropAndMoveAndCapture(let piece,
                                        _,
                                        _,
                                        let capturedPiece,
                                        let capturedPieceIndex):
                self.drop(piece: piece,
                          index: capturedPieceIndex,
                          dropAction: action)
                self.fadeout(piece: capturedPiece)
                self.playSound(piece,
                               kind: .put,
                               delay: PieceAnimation.drop.duration)
                self.remove(capturedPiece,
                            delay: PieceAnimation.fadeout.duration)
            case .undo, .reset:
                break
        }
    }
    private func setPosition(piece: Piece,
                             index: Index,
                             picked: Bool) {
        let pieceEntity = self.pieceEntity(piece)!
        pieceEntity.setPosition(index.position, relativeTo: self.root)
        self.pieceBodyEntity(piece)!.setPosition([0,
                                                  picked ? Size.Meter.pickedOffset : 0,
                                                  0],
                                                 relativeTo: pieceEntity)
    }
    private func setPosition(piece: Piece,
                             dragAction: Action) {
        let pieceEntity = self.pieceEntity(piece)!
        pieceEntity.setPosition(dragAction.draggedPiecePosition,
                                relativeTo: self.root)
        self.pieceBodyEntity(piece)!.setPosition([0,
                                                  dragAction.draggedPieceBodyYOffset,
                                                  0],
                                                 relativeTo: pieceEntity)
    }
    private func moveUp(piece: Piece,
                        index: Index) {
        self.pieceBodyEntity(piece)!.playAnimation(
            try! .makeActionAnimation(
                for: FromToByAction(to: Transform(translation: [0,
                                                                Size.Meter.pickedOffset,
                                                                0]),
                                    mode: .parent,
                                    timing: .easeInOut),
                duration: PieceAnimation.vertical.duration,
                bindTarget: .transform
            )
        )
    }
    private func moveDown(piece: Piece,
                          index: Index,
                          delay: TimeInterval = 0) {
        self.pieceBodyEntity(piece)!.playAnimation(
            try! .makeActionAnimation(
                for: FromToByAction(to: .identity,
                                    mode: .parent,
                                    timing: .easeInOut),
                duration: PieceAnimation.vertical.duration,
                bindTarget: .transform,
                delay: delay
            )
        )
    }
    private func moveHorizontally(piece: Piece,
                                  exIndex: Index,
                                  newIndex: Index) {
        self.pieceEntity(piece)!.playAnimation(
            try! .makeActionAnimation(
                for: FromToByAction(from: Transform(translation: exIndex.position),
                                    to: Transform(translation: newIndex.position),
                                    mode: .parent,
                                    timing: .easeInOut),
                duration: PieceAnimation.horizontal.duration,
                bindTarget: .transform
            )
        )
    }
    private func fadeout(piece: Piece,
                         delay: TimeInterval = 0) {
        self.pieceEntity(piece)!.playAnimation(
            try! .makeActionAnimation(for: FromToByAction<Float>(to: 0.0),
                                      duration: PieceAnimation.fadeout.duration,
                                      bindTarget: .opacity,
                                      delay: delay)
        )
    }
    private func drop(piece: Piece,
                      index: Index,
                      dropAction: Action) {
        self.pieceBodyEntity(piece)!.playAnimation(
            try! .makeActionAnimation(
                for: FromToByAction(from: Transform(translation: [0,
                                                                  dropAction.draggedPieceBodyYOffset,
                                                                  0]),
                                    to: .identity,
                                    mode: .parent,
                                    timing: .easeInOut),
                duration: PieceAnimation.drop.duration,
                bindTarget: .transform
            )
        )
        self.pieceEntity(piece)!.playAnimation(
            try! .makeActionAnimation(
                for: FromToByAction(from: Transform(translation: dropAction.draggedPiecePosition),
                                    to: Transform(translation: index.position),
                                    mode: .parent,
                                    timing: .easeInOut),
                duration: PieceAnimation.drop.duration,
                bindTarget: .transform
            )
        )
    }
    private func playSound(_ piece: Piece,
                           kind: Sound.Piece,
                           delay: TimeInterval = 0) {
        guard self.root.isActive else { return }
        self.pieceEntity(piece)?
            .findEntity(named: "sound")!
            .playAnimation(
                try! .makeActionAnimation(for: Sound.asAction(kind,
                                                              gain: kind == .put ? 18 : 0), //TODO: 再検討
                                          delay: delay)
            )
    }
    private func disableInputDuringAnimation(_ pieces: Pieces) {
        guard let currentAction = pieces.currentAction,
              currentAction.hasAnimation else {
            self.enableInputWithoutPickedPiece(pieces)
            return
        }
        pieces.all.forEach {
            self.pieceBodyEntity($0)?
                .components
                .remove(InputTargetComponent.self)
        }
        Task {
            try? await Task.sleep(for: .seconds(PieceAnimation.wholeDuration(currentAction)))
            self.enableInputWithoutPickedPiece(pieces)
        }
    }
    private func enableInputWithoutPickedPiece(_ pieces: Pieces) {
        pieces
            .all
            .filter { $0 != pieces.pickingPiece }
            .forEach {
                self.pieceBodyEntity($0)?
                    .components
                    .set(InputTargetComponent())
            }
    }
    private func updatePieceOpacityDuringDragging(_ pieces: Pieces) {
        for piece in pieces.all {
            guard piece != pieces.draggingPiece else { continue }
            self.pieceEntity(piece)?.components[OpacityComponent.self]!.opacity = 1.0
        }
        guard let draggingPiece = pieces.draggingPiece,
              let draggedPieceBodyPosition = pieces.currentAction?.draggedPieceBodyPosition else {
            return
        }
        let closestIndex = Index.calculateFromDrag(bodyPosition: draggedPieceBodyPosition)
        guard let closestPiece = pieces.piece(closestIndex),
              draggingPiece != closestPiece,
              let closestPieceEntity = self.pieceEntity(closestPiece) else {
            return
        }
        let draggedPieceBodyPosition2D = SIMD2<Float>(x: draggedPieceBodyPosition.x,
                                                      y: draggedPieceBodyPosition.z)
        let closestIndexPosition2D = SIMD2<Float>(x: closestIndex.position.x,
                                                  y: closestIndex.position.z)
        let distance = distance(draggedPieceBodyPosition2D, closestIndexPosition2D)
        let radius = Size.Meter.square / 2
        if distance < radius {
            closestPieceEntity.components[OpacityComponent.self]!.opacity = distance / radius
        } else {
            closestPieceEntity.components[OpacityComponent.self]!.opacity = 1.0
        }
    }
    private func playResetSoundFromBoard(_ currentAction: Action) {
        if currentAction == .reset { Sound.Board.playReset(self.root) }
    }
}




//func applyDraggingPiecePosition(_ pieceEntity: Entity, _ newPiece: Piece) {
//    self.disablePieceHoverEffect()
//    pieceEntity.findEntity(named: "body")!.position.y = newPiece.bodyYOffset
//    pieceEntity.setPosition(newPiece.position, relativeTo: self.root)
//    pieceEntity.components[Piece.self] = newPiece
//}
//func applyPieceDrop(_ pieceEntity: Entity, _ newPiece: Piece) async {
//    let duration = 0.5
//    pieceEntity.findEntity(named: "body")!.move(to: Transform(),
//                                                relativeTo: pieceEntity,
//                                                duration: duration)
//    pieceEntity.move(to: Transform(translation: newPiece.position),
//                     relativeTo: self.root,
//                     duration: duration)
//    pieceEntity.components[Piece.self] = newPiece
//    try? await Task.sleep(for: .seconds(duration))
//    self.applyPiecePromotion(pieceEntity, newPiece)
//    self.activatePieceHoverEffect()
//}
//func applyPieceMove(_ pieceEntity: Entity, _ exPiece: Piece, _ newPiece: Piece) async {
//    if !exPiece.picked {
//        await self.raisePiece(pieceEntity, exPiece.index)
//    }
//    let duration: TimeInterval = 1
//    pieceEntity.move(to: .init(translation: newPiece.index.position),
//                     relativeTo: self.root,
//                     duration: duration)
//    try? await Task.sleep(for: .seconds(duration))
//    await self.lowerPiece(pieceEntity, newPiece.index)
//}
//func applyPiecePickingState(_ pieceEntity: Entity, _ exPiece: Piece, _ newPiece: Piece) async {
//    var translation = exPiece.index.position
//    translation.y = newPiece.picked ? Size.Meter.pickedOffset : 0
//    let duration: TimeInterval = 0.6
//    pieceEntity.findEntity(named: "body")!.move(to: .init(translation: translation),
//                                                relativeTo: self.root,
//                                                duration: duration)
//    pieceEntity.setPosition(newPiece.position, relativeTo: self.root)
//    try? await Task.sleep(for: .seconds(duration))
//}
//private func raisePiece(_ entity: Entity, _ index: Index) async {
//    var translation = index.position
//    translation.y = Size.Meter.pickedOffset
//    let duration: TimeInterval = 0.6
//    let pieceBodyEntity = entity.findEntity(named: "body")!
//    pieceBodyEntity.move(to: .init(translation: translation),
//                         relativeTo: self.root,
//                         duration: duration)
//    try? await Task.sleep(for: .seconds(duration))
//}
//private func lowerPiece(_ entity: Entity, _ index: Index) async {
//    let duration: TimeInterval = 0.7
//    let pieceBodyEntity = entity.findEntity(named: "body")!
//    pieceBodyEntity.move(to: .init(translation: index.position),
//                         relativeTo: self.root,
//                         duration: duration)
//    try? await Task.sleep(for: .seconds(duration))
//}
