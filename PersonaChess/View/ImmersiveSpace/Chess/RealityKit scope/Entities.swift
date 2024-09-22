import RealityKit
import Foundation

@MainActor
class Entities {
    let root = Entity()
}

extension Entities {
    var pickedPieceEntity: Entity? {
        self.root.children.first { $0.components[Piece.self]?.picked == true }
    }
    func applyDraggingPiecePosition(_ pieceEntity: Entity, _ newPiece: Piece) {
        self.disablePieceHoverEffect()
        pieceEntity.findEntity(named: "body")!.position.y = newPiece.bodyYOffset
        pieceEntity.setPosition(newPiece.position, relativeTo: self.root)
        pieceEntity.components[Piece.self] = newPiece
    }
    func applyPieceDrop(_ pieceEntity: Entity, _ newPiece: Piece) async {
        let duration = 0.5
        pieceEntity.findEntity(named: "body")!.move(to: Transform(),
                                                    relativeTo: pieceEntity,
                                                    duration: duration)
        pieceEntity.move(to: Transform(translation: newPiece.position),
                         relativeTo: self.root,
                         duration: duration)
        pieceEntity.components[Piece.self] = newPiece
        try? await Task.sleep(for: .seconds(duration))
        self.applyPiecePromotion(pieceEntity, newPiece)
        self.activatePieceHoverEffect()
    }
    func applyPieceMove(_ pieceEntity: Entity, _ exPiece: Piece, _ newPiece: Piece) async {
        if !exPiece.picked {
            await self.raisePiece(pieceEntity, exPiece.index)
        }
        let duration: TimeInterval = 1
        pieceEntity.move(to: .init(translation: newPiece.index.position),
                         relativeTo: self.root,
                         duration: duration)
        try? await Task.sleep(for: .seconds(duration))
        await self.lowerPiece(pieceEntity, newPiece.index)
    }
    func applyPiecePickingState(_ pieceEntity: Entity, _ exPiece: Piece, _ newPiece: Piece) async {
        var translation = exPiece.index.position
        translation.y = newPiece.picked ? Size.Meter.pickedOffset : 0
        let duration: TimeInterval = 0.6
        pieceEntity.findEntity(named: "body")!.move(to: .init(translation: translation),
                                                    relativeTo: self.root,
                                                    duration: duration)
        pieceEntity.setPosition(newPiece.position, relativeTo: self.root)
        try? await Task.sleep(for: .seconds(duration))
    }
    func applyPiecePromotion(_ pieceEntity: Entity, _ newPiece: Piece) {
        pieceEntity.findEntity(named: "promotionMark")?.isEnabled = newPiece.promotion
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
    static func updateInputtablity(_ pieceEntity: Entity) {
        let piece: Piece = pieceEntity.components[Piece.self]!
        let pieceBodyEntity = pieceEntity.findEntity(named: "body")!
        if piece.picked {
            pieceBodyEntity.components.remove(CollisionComponent.self)
            pieceBodyEntity.components.remove(InputTargetComponent.self)
        } else {
            pieceBodyEntity.components.set([
                PieceEntity.collisionComponent(entity: pieceEntity),
                InputTargetComponent()
            ])
        }
    }
}

private extension Entities {
    private func raisePiece(_ entity: Entity, _ index: Index) async {
        var translation = index.position
        translation.y = Size.Meter.pickedOffset
        let duration: TimeInterval = 0.6
        let pieceBodyEntity = entity.findEntity(named: "body")!
        pieceBodyEntity.move(to: .init(translation: translation),
                             relativeTo: self.root,
                             duration: duration)
        try? await Task.sleep(for: .seconds(duration))
    }
    private func lowerPiece(_ entity: Entity, _ index: Index) async {
        let duration: TimeInterval = 0.7
        let pieceBodyEntity = entity.findEntity(named: "body")!
        pieceBodyEntity.move(to: .init(translation: index.position),
                             relativeTo: self.root,
                             duration: duration)
        try? await Task.sleep(for: .seconds(duration))
    }
}
