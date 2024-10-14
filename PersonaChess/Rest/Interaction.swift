import RealityKit
import SwiftUI

enum Interaction: Equatable {
    case tapPiece(Entity),
         tapSquare(Index),
         drag(Piece, translation: SIMD3<Float>),
         drop(Piece, dragTranslation: SIMD3<Float>)
}
