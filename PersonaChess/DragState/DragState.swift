import Foundation

struct DragState {
    let id: UUID
    let piece: Piece
    let sourceIndex: Index
    var isFirst: Bool = true
    var translation: SIMD3<Float>
    
    init(_ piece: Piece, _ sourceIndex: Index, _ translation: SIMD3<Float>) {
        self.id = UUID()
        self.piece = piece
        self.sourceIndex = sourceIndex
        self.translation = translation
    }
}

extension DragState: Codable, Equatable {
    func updating(_ translation: SIMD3<Float>) -> Self {
        var newValue = self
        newValue.isFirst = false
        newValue.translation = translation
        return newValue
    }
    
    var draggedPiecePosition: SIMD3<Float> {
        .init(x: self.draggedPieceBodyPosition.x,
              y: 0,
              z: self.draggedPieceBodyPosition.z)
    }
    
    var draggedPieceBodyYOffset: Float {
        self.draggedPieceBodyPosition.y
    }
    
    var draggedPieceBodyPosition: SIMD3<Float> {
        var value = self.translation
        if self.translation.y < 0 {
            value.y = 0
        }
        return self.sourceIndex.position + value
    }
}
