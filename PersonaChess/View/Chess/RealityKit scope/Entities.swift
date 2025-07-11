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
        
        self.enableHoverEffect(pieces)
        
        self.disableInputDuringAnimation(pieces)
        
        self.updatePieceOpacity(pieces)
        
        self.setPiecesPositionWithoutAnimation(pieces)
        
        guard let currentAction = pieces.currentAction else { return }
        
        self.setPositionBeforeAnimation(currentAction)
        
        self.updateWithAnimation(currentAction)
        
        self.playResetSoundFromBoard(currentAction)
    }
    
    func dragUpdate(_ pieces: Pieces,
                    _ state: DragState) {
        self.stopAllAnimations()
        
        self.disableHoverEffect()
        
        self.updatePieceOpacity(pieces,
                                dragState: state)
        
        self.setPosition(dragState: state)
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
                switch pieces.currentAction {
                    case .dropAndMoveAndCapture(_, _, _),
                            .tapPieceAndMoveAndCapture(_, _, _, _),
                            .remove(_):
                        continue
                    default:
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
    private func enableHoverEffect(_ pieces: Pieces) {
        let bodyEntities: [Entity] = {
            self.root
                .children
                .filter { $0.components.has(Piece.self) }
                .map { $0.findEntity(named: "body")! }
        }()
        for bodyEntity in bodyEntities {
            if let currentAction = pieces.currentAction,
               currentAction.hasAnimation {
                Task {
                    try? await Task.sleep(for: .seconds(PieceAnimation.wholeDuration(currentAction)))
                    bodyEntity.components.set(HoverEffectComponent())
                }
            } else {
                bodyEntity.components.set(HoverEffectComponent())
            }
        }
    }
    private func disableHoverEffect() {
        self.root
            .children
            .filter { $0.components.has(Piece.self) }
            .map { $0.findEntity(named: "body")! }
            .forEach { $0.components.remove(HoverEffectComponent.self) }
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
            case .dropAndBack(let dragState),
                    .dropAndMove(let dragState, _),
                    .dropAndMoveAndCapture(let dragState, _, _):
                self.setPosition(dragState: dragState)
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
            case .beginDrag(let dragState):
                self.setPosition(dragState: dragState)
                if dragState.isFirst {
                    self.playSound(dragState.piece,
                                   kind: .select)
                }
            case .dropAndBack(let dragState):
                self.drop(piece: dragState.piece,
                          index: dragState.sourceIndex,
                          dragState: dragState)
            case .dropAndMove(let dragState, let newIndex):
                self.drop(piece: dragState.piece,
                          index: newIndex,
                          dragState: dragState)
                self.playSound(dragState.piece,
                               kind: .put,
                               delay: PieceAnimation.drop.duration)
            case .dropAndMoveAndCapture(let dragState,
                                        let capturedPiece,
                                        let capturedPieceIndex):
                self.drop(piece: dragState.piece,
                          index: capturedPieceIndex,
                          dragState: dragState)
                self.fadeout(piece: capturedPiece)
                self.playSound(dragState.piece,
                               kind: .put,
                               delay: PieceAnimation.drop.duration)
                self.remove(capturedPiece,
                            delay: PieceAnimation.fadeout.duration)
            case .remove(let piece):
                self.fadeout(piece: piece)
                self.playSound(piece,
                               kind: .remove)
                self.remove(piece,
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
    private func setPosition(dragState: DragState) {
        let pieceEntity = self.pieceEntity(dragState.piece)!
        pieceEntity.setPosition(dragState.draggedPiecePosition,
                                relativeTo: self.root)
        self.pieceBodyEntity(dragState.piece)!.setPosition([0,
                                                            dragState.draggedPieceBodyYOffset,
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
                      dragState: DragState) {
        self.pieceBodyEntity(piece)!.playAnimation(
            try! .makeActionAnimation(
                for: FromToByAction(from: Transform(translation: [0,
                                                                  dragState.draggedPieceBodyYOffset,
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
                for: FromToByAction(from: Transform(translation: dragState.draggedPiecePosition),
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
                                                              gain: kind == .put ? 18 : 0), //TODO: reconsider
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
    private func updatePieceOpacity(_ pieces: Pieces,
                                    dragState: DragState? = nil) {//TODO: reconsider
        for piece in pieces.all {
            guard piece != pieces.draggingPiece else { continue }
            self.pieceEntity(piece)?.components[OpacityComponent.self]!.opacity = 1.0
        }
        guard let draggingPiece = pieces.draggingPiece,
              let draggedPieceBodyPosition = dragState?.draggedPieceBodyPosition else {
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
