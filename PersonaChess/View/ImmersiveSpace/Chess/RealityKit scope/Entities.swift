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
    func pieceEntity(_ piece: Piece) -> Entity? {
        self.root
            .children
            .filter { $0.components.has(Piece.self) }
            .first { $0.components[Piece.self]! == piece }
    }
    func pieceBodyEntity(_ piece: Piece) -> Entity? {
        self.pieceEntity(piece)?.findEntity(named: "body")
    }
    func add(_ piece: Piece, index: Index) {
        if !self.root.children.contains(where: { $0.components[Piece.self] == piece }) {
            self.root.addChild(PieceEntity.load(piece, index))
        }
    }
    func remove(_ piece: Piece) {
        if let entity = self.root.children.first(where: { $0.components[Piece.self] == piece }) {
            entity.removeFromParent()
        }
    }
    func setPositionWithoutAnimation(_ piece: Piece, _ index: Index) {
        self.pieceEntity(piece)?.setPosition(index.position,
                                             relativeTo: self.root)
        self.pieceBodyEntity(piece)?.setPosition(.zero,
                                                 relativeTo: self.pieceEntity(piece))
    }
    func updateWithAnimation(_ action: Action?) {
        switch action {
            case .tapPieceAndPick(let piece, let index):
                self.slideUp(piece: piece,
                             index: index,
                             dulation: 0.6)
            case .tapPieceAndChangePickingPiece(let exPickedPiece,
                                                let exPickedPieceIndex,
                                                let newPickedPiece,
                                                let newPickedPieceIndex):
                self.slideDown(piece: exPickedPiece,
                               index: exPickedPieceIndex,
                               dulation: 0.6)
                self.slideUp(piece: newPickedPiece,
                             index: newPickedPieceIndex,
                             dulation: 0.6)
            case .tapPieceAndMoveAndCapture(let pickedPiece,
                                            let pickedPieceIndex,
                                            let capturedPiece,
                                            let capturedPieceIndex):
                let pickedPieceEntity = self.pieceEntity(pickedPiece)!
                pickedPieceEntity.setPosition(pickedPieceIndex.position,
                                              relativeTo: self.root)
                pickedPieceEntity.setPosition([0, Size.Meter.pickedOffset, 0],
                                              relativeTo: pickedPieceEntity)
                self.pieceEntity(capturedPiece)!.setPosition(capturedPieceIndex.position,
                                                             relativeTo: self.root)
                let horizontalSlideDuration = 1.0
                self.pieceEntity(pickedPiece)!.playAnimation(
                    try! .makeActionAnimation(
                        for: FromToByAction(from: Transform(translation: pickedPieceIndex.position),
                                            to: Transform(translation: capturedPieceIndex.position),
                                            mode: .parent,
                                            timing: .easeInOut),
                        duration: horizontalSlideDuration,
                        bindTarget: .transform
                    )
                )
                let verticalSlideDuration = 0.6
                self.pieceBodyEntity(pickedPiece)!.playAnimation(
                    try! .makeActionAnimation(
                        for: FromToByAction(to: .identity,
                                            mode: .parent,
                                            timing: .easeInOut),
                        duration: verticalSlideDuration,
                        bindTarget: .transform,
                        delay: horizontalSlideDuration
                    )
                )
                self.pieceEntity(capturedPiece)!.playAnimation(
                    try! .makeActionAnimation(
                        for: FromToByAction<Float>(to: 0.0),
                        duration: 0.3,
                        bindTarget: .opacity,
                        delay: horizontalSlideDuration
                    )
                )
                Task {
                    try? await Task.sleep(for: .seconds(horizontalSlideDuration + verticalSlideDuration))
                    self.remove(capturedPiece)
                }
            case .tapSquareAndUnpick(let piece, _):
                self.pieceBodyEntity(piece)!.playAnimation(
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
                self.pieceEntity(piece)!.playAnimation(
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
                self.pieceBodyEntity(piece)!.playAnimation(
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
                self.pieceBodyEntity(piece)!.position.y = draggedPieceBodyPosition.y
                self.pieceEntity(piece)!.setPosition(.init(x: draggedPieceBodyPosition.x,
                                                           y: 0,
                                                           z: draggedPieceBodyPosition.z),
                                                     relativeTo: self.root)
            case .dropAndBack(let piece, let sourceIndex, let dragTranslation):
                let draggedPieceBodyPosition = {
                    var resultTranslation = dragTranslation
                    if dragTranslation.y < 0 {
                        resultTranslation.y = 0
                    }
                    return sourceIndex.position + resultTranslation
                }()
                self.pieceBodyEntity(piece)!.position.y = draggedPieceBodyPosition.y
                let draggedPiecePosition: SIMD3<Float> = .init(x: draggedPieceBodyPosition.x,
                                                               y: 0,
                                                               z: draggedPieceBodyPosition.z)
                self.pieceEntity(piece)!.setPosition(draggedPiecePosition,
                                                     relativeTo: self.root)
                let duration = 0.7
                self.pieceBodyEntity(piece)!.playAnimation(
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
                self.pieceEntity(piece)!.playAnimation(
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
                self.pieceBodyEntity(piece)!.position.y = draggedPieceBodyPosition.y
                let draggedPiecePosition: SIMD3<Float> = .init(x: draggedPieceBodyPosition.x,
                                                               y: 0,
                                                               z: draggedPieceBodyPosition.z)
                self.pieceEntity(piece)!.setPosition(draggedPiecePosition,
                                                     relativeTo: self.root)
                let duration = 0.7
                self.pieceBodyEntity(piece)!.playAnimation(
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
                self.pieceEntity(piece)!.playAnimation(
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
                self.pieceBodyEntity(piece)!.position.y = draggedPieceBodyPosition.y
                let draggedPiecePosition: SIMD3<Float> = .init(x: draggedPieceBodyPosition.x,
                                                               y: 0,
                                                               z: draggedPieceBodyPosition.z)
                self.pieceEntity(piece)!.setPosition(draggedPiecePosition,
                                                     relativeTo: self.root)
                let duration = 0.7
                self.pieceBodyEntity(piece)!.playAnimation(
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
                self.pieceEntity(piece)!.playAnimation(
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
                self.pieceEntity(capturedPiece)!.playAnimation(
                    try! .makeActionAnimation(
                        for: FromToByAction<Float>(to: 0.0),
                        duration: duration,
                        bindTarget: .opacity
                    )
                )
                Task {
                    try? await Task.sleep(for: .seconds(duration))
                    self.remove(capturedPiece)
                }
            case .undo, .reset, .none:
                break
        }
    }
    func applyPiecePromotion(_ piece: Piece, _ promotion: Bool?) {
        guard piece.chessmen.role == .pawn,
              let pieceEntity = self.pieceEntity(piece) else {
            return
        }
        if promotion == true {
            PieceEntity.addPromotionMarkEntity(pieceEntity, piece.side)
        } else {
            PieceEntity.removePromotionMarkEntity(pieceEntity)
        }
    }
    func disablePieceHoverEffect() {
        self.root
            .children
            .filter { $0.components.has(Piece.self) }
            .forEach { $0.findEntity(named: "body")!.components.remove(HoverEffectComponent.self) }
    }
    func activatePieceHoverEffect() {
        self.root
            .children
            .filter { $0.components.has(Piece.self) }
            .forEach { $0.findEntity(named: "body")!.components.set(HoverEffectComponent()) }
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
    //static func updatePickingInputtablity(_ pieceEntity: Entity) {
    //    let piece: Piece = pieceEntity.components[Piece.self]!
    //    let pieceBodyEntity = pieceEntity.findEntity(named: "body")!
    //    if piece.picked {
    //        pieceBodyEntity.components.remove(InputTargetComponent.self)
    //    } else {
    //        pieceBodyEntity.components.set(InputTargetComponent())
    //    }
    //}
}

private extension Entities {
    private func slideUp(piece: Piece, index: Index, dulation: TimeInterval) {
        self.pieceEntity(piece)!.setPosition(index.position,
                                             relativeTo: self.root)
        self.pieceBodyEntity(piece)!.playAnimation(
            try! .makeActionAnimation(
                for: FromToByAction(to: Transform(translation: [0, Size.Meter.pickedOffset, 0]),
                                    mode: .parent,
                                    timing: .easeInOut),
                duration: dulation,
                bindTarget: .transform
            )
        )
    }
    private func slideDown(piece: Piece, index: Index, dulation: TimeInterval) {
        self.pieceEntity(piece)!.setPosition(index.position,
                                             relativeTo: self.root)
        self.pieceBodyEntity(piece)!.playAnimation(
            try! .makeActionAnimation(
                for: FromToByAction(to: .identity,
                                    mode: .parent,
                                    timing: .easeInOut),
                duration: dulation,
                bindTarget: .transform
            )
        )
    }
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
