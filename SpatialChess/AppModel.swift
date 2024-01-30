import SwiftUI
import RealityKit

class AppModel: ObservableObject {
    @Published var gameState: GameState = .preset
    @Published var selected: Index? = nil
    var rootEntity: Entity = .init()
}
