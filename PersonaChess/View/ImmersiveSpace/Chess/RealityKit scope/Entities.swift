import RealityKit
import Foundation

@MainActor
class Entities {
    let root = Entity()
    
    init() {
        Pieces.preset.indices.forEach {
            self.root.addChild(PieceEntity.load($0.key, $0.value))
        }
    }
}

extension Entities {
    func update(_ pieces: Pieces) {
        self.addOrRemovePieceEntities(pieces)
        
        self.setPawnPromotion(pieces)
        
        self.updateHoverEffect(disabled: pieces.isDragging)
        
        self.updatePickedPieceInputability(pieces)
        
        self.setPiecesPositionWithoutAnimation(pieces)
        
        guard let currentAction = pieces.currentAction else { return }
        
        self.setPositionBeforeAnimation(currentAction)
        
        self.updateWithAnimation(currentAction)
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
    private func remove(_ piece: Piece) {
        self.pieceEntity(piece)?.removeFromParent()
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
    private func setPawnPromotion(_ pieces: Pieces) {
        for piece in pieces.list {
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
    private func updatePickedPieceInputability(_ pieces: Pieces) {
        for piece in pieces.list {
            let isPicking = (piece == pieces.pickingPiece)
            guard let pieceBodyEntity = self.pieceBodyEntity(piece) else {
                assertionFailure(); continue
            }
            if isPicking {
                pieceBodyEntity.components.remove(InputTargetComponent.self)
            } else {
                pieceBodyEntity.components.set(InputTargetComponent())
            }
        }
    }
    private func setPiecesPositionWithoutAnimation(_ pieces: Pieces) {
        for piece in pieces.list {
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
            case .drag(let piece, _, _),
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
                            index: index,
                            duration: 0.6)
            case .tapPieceAndChangePickingPiece(let exPickedPiece,
                                                let exPickedPieceIndex,
                                                let newPickedPiece,
                                                let newPickedPieceIndex):
                self.moveDown(piece: exPickedPiece,
                              index: exPickedPieceIndex,
                              duration: 0.6)
                self.moveUp(piece: newPickedPiece,
                            index: newPickedPieceIndex,
                            duration: 0.6)
            case .tapPieceAndMoveAndCapture(let pickedPiece,
                                            let pickedPieceIndex,
                                            let capturedPiece,
                                            let capturedPieceIndex):
                let horizontalDuration = 1.0
                let downDuration = 0.6
                let fadeoutDuration = 0.3
                Task {
                    self.moveHorizontally(piece: pickedPiece,
                                          exIndex: pickedPieceIndex,
                                          newIndex: capturedPieceIndex,
                                          duration: horizontalDuration)
                    try? await Task.sleep(for: .seconds(horizontalDuration))
                    self.moveDown(piece: pickedPiece,
                                  index: capturedPieceIndex,
                                  duration: downDuration)
                    self.fadeout(piece: capturedPiece,
                                 duration: fadeoutDuration)
                    try? await Task.sleep(for: .seconds(horizontalDuration + fadeoutDuration))
                    self.remove(capturedPiece)
                }
            case .tapSquareAndUnpick(let piece, let index):
                self.moveDown(piece: piece,
                              index: index,
                              duration: 0.6)
            case .tapSquareAndMove(let piece, let exIndex, let newIndex):
                let horizontalDuration = 1.0
                Task {
                    self.moveHorizontally(piece: piece,
                                          exIndex: exIndex,
                                          newIndex: newIndex,
                                          duration: horizontalDuration)
                    try? await Task.sleep(for: .seconds(horizontalDuration))
                    self.moveDown(piece: piece,
                                  index: newIndex,
                                  duration: 0.6)
                }
            case .drag(let piece, _, _):
                self.setPosition(piece: piece,
                                 dragAction: action)
            case .dropAndBack(let piece, let sourceIndex, _):
                self.drop(piece: piece,
                          index: sourceIndex,
                          dropAction: action,
                          duration: 0.7)
            case .dropAndMove(let piece, _, _, let newIndex):
                self.drop(piece: piece,
                          index: newIndex,
                          dropAction: action,
                          duration: 0.7)
            case .dropAndMoveAndCapture(let piece,
                                        _,
                                        _,
                                        let capturedPiece,
                                        let capturedPieceIndex):
                let fadeoutDuration = 0.3
                self.drop(piece: piece,
                          index: capturedPieceIndex,
                          dropAction: action,
                          duration: 0.7)
                self.fadeout(piece: capturedPiece,
                             duration: fadeoutDuration)
                Task {
                    try? await Task.sleep(for: .seconds(fadeoutDuration))
                    self.remove(capturedPiece)
                }
            case .undo, .reset:
                break
        }
    }
    private func setPosition(piece: Piece, index: Index, picked: Bool) {
        let pieceEntity = self.pieceEntity(piece)!
        pieceEntity.setPosition(index.position, relativeTo: self.root)
        self.pieceBodyEntity(piece)!.setPosition([0,
                                                  picked ? Size.Meter.pickedOffset : 0,
                                                  0],
                                                 relativeTo: pieceEntity)
    }
    private func setPosition(piece: Piece, dragAction: Action) {
        let pieceEntity = self.pieceEntity(piece)!
        pieceEntity.setPosition(dragAction.draggedPiecePosition,
                                relativeTo: self.root)
        self.pieceBodyEntity(piece)!.setPosition([0,
                                                  dragAction.draggedPieceBodyYOffset,
                                                  0],
                                                 relativeTo: pieceEntity)
    }
    private func moveUp(piece: Piece, index: Index, duration: TimeInterval) {
        self.pieceBodyEntity(piece)!.playAnimation(
            try! .makeActionAnimation(
                for: FromToByAction(to: Transform(translation: [0,
                                                                Size.Meter.pickedOffset,
                                                                0]),
                                    mode: .parent,
                                    timing: .easeInOut),
                duration: duration,
                bindTarget: .transform
            )
        )
    }
    private func moveDown(piece: Piece, index: Index, duration: TimeInterval) {
        self.pieceBodyEntity(piece)!.playAnimation(
            try! .makeActionAnimation(
                for: FromToByAction(to: .identity,
                                    mode: .parent,
                                    timing: .easeInOut),
                duration: duration,
                bindTarget: .transform
            )
        )
    }
    private func moveHorizontally(piece: Piece,
                                  exIndex: Index,
                                  newIndex: Index,
                                  duration: TimeInterval) {
        self.pieceEntity(piece)!.playAnimation(
            try! .makeActionAnimation(
                for: FromToByAction(from: Transform(translation: exIndex.position),
                                    to: Transform(translation: newIndex.position),
                                    mode: .parent,
                                    timing: .easeInOut),
                duration: duration,
                bindTarget: .transform
            )
        )
    }
    private func fadeout(piece: Piece, duration: TimeInterval) {
        self.pieceEntity(piece)!.playAnimation(
            try! .makeActionAnimation(
                for: FromToByAction<Float>(to: 0.0),
                duration: duration,
                bindTarget: .opacity
            )
        )
    }
    private func drop(piece: Piece, index: Index, dropAction: Action, duration: TimeInterval) {
        self.pieceBodyEntity(piece)!.playAnimation(
            try! .makeActionAnimation(
                for: FromToByAction(from: Transform(translation: [0,
                                                                  dropAction.draggedPieceBodyYOffset,
                                                                  0]),
                                    to: .identity,
                                    mode: .parent,
                                    timing: .easeInOut),
                duration: duration,
                bindTarget: .transform
            )
        )
        self.pieceEntity(piece)!.playAnimation(
            try! .makeActionAnimation(
                for: FromToByAction(from: Transform(translation: dropAction.draggedPiecePosition),
                                    to: Transform(translation: index.position),
                                    mode: .parent,
                                    timing: .easeInOut),
                duration: duration,
                bindTarget: .transform
            )
        )
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
}
