import RealityKit
import SwiftUI

enum Interaction: Equatable {
    case tapPiece(Entity),
         tapSquare(Index),
         drag(EntityTargetValue<DragGesture.Value>),
         drop(EntityTargetValue<DragGesture.Value>)
}
