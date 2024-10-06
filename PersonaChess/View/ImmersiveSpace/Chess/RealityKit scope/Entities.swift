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
    private var pieces: [Entity] {
        self.root
            .scene?
            .performQuery(.init(where: .has(Piece.self)))
            .map { $0 } ?? []
    }
    func piece(_ piece: Piece) -> Entity? {//TODO: リファクタリング
        self.pieces.first { $0.components[Piece.self]! == piece }
    }
    func pieceBody(_ piece: Piece) -> Entity? {
        self.piece(piece)?.findEntity(named: "body")
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
//    func applyDraggingPiecePosition(_ pieceEntity: Entity, _ newPiece: Piece) {
//        self.disablePieceHoverEffect()
//        pieceEntity.findEntity(named: "body")!.position.y = newPiece.bodyYOffset
//        pieceEntity.setPosition(newPiece.position, relativeTo: self.root)
//        pieceEntity.components[Piece.self] = newPiece
//    }
//    func applyPieceDrop(_ pieceEntity: Entity, _ newPiece: Piece) async {
//        let duration = 0.5
//        pieceEntity.findEntity(named: "body")!.move(to: Transform(),
//                                                    relativeTo: pieceEntity,
//                                                    duration: duration)
//        pieceEntity.move(to: Transform(translation: newPiece.position),
//                         relativeTo: self.root,
//                         duration: duration)
//        pieceEntity.components[Piece.self] = newPiece
//        try? await Task.sleep(for: .seconds(duration))
//        self.applyPiecePromotion(pieceEntity, newPiece)
//        self.activatePieceHoverEffect()
//    }
//    func applyPieceMove(_ pieceEntity: Entity, _ exPiece: Piece, _ newPiece: Piece) async {
//        if !exPiece.picked {
//            await self.raisePiece(pieceEntity, exPiece.index)
//        }
//        let duration: TimeInterval = 1
//        pieceEntity.move(to: .init(translation: newPiece.index.position),
//                         relativeTo: self.root,
//                         duration: duration)
//        try? await Task.sleep(for: .seconds(duration))
//        await self.lowerPiece(pieceEntity, newPiece.index)
//    }
//    func applyPiecePickingState(_ pieceEntity: Entity, _ exPiece: Piece, _ newPiece: Piece) async {
//        var translation = exPiece.index.position
//        translation.y = newPiece.picked ? Size.Meter.pickedOffset : 0
//        let duration: TimeInterval = 0.6
//        pieceEntity.findEntity(named: "body")!.move(to: .init(translation: translation),
//                                                    relativeTo: self.root,
//                                                    duration: duration)
//        pieceEntity.setPosition(newPiece.position, relativeTo: self.root)
//        try? await Task.sleep(for: .seconds(duration))
//    }
    func applyPiecePromotion(_ piece: Piece, _ promotion: Bool) {
        guard piece.chessmen.role == .pawn else {
            return
        }
        guard let pieceEntity = self.piece(piece) else {
            assertionFailure(); return
        }
        if promotion {
            if pieceEntity.findEntity(named: "promotionMark") == nil {
                PieceEntity.addPromotionMarkEntity(pieceEntity, piece.side)
            }
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
//    static func updatePickingInputtablity(_ pieceEntity: Entity) {
//        let piece: Piece = pieceEntity.components[Piece.self]!
//        let pieceBodyEntity = pieceEntity.findEntity(named: "body")!
//        if piece.picked {
//            pieceBodyEntity.components.remove(InputTargetComponent.self)
//        } else {
//            pieceBodyEntity.components.set(InputTargetComponent())
//        }
//    }
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
