import SwiftUI
import RealityKit

class AppModel: ObservableObject {
    @Published var gameState: GameState = .preset
    var rootEntity: Entity = .init()
}
