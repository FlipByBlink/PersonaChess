import SwiftUI
import RealityKit

struct ContentView: View {
    @State private var rootEntity: Entity = .init()
    var body: some View {
        RealityView { content in
            self.rootEntity.position.y = 1.2
            self.rootEntity.position.z = -1
            GameState.preset.forEach { (key: GameState.Position, value: Piece) in
                let entity = try! Entity.load(named: value.assetName)
                entity.position = key.position
                self.rootEntity.addChild(entity)
            }
            content.add(self.rootEntity)
        }
    }
}
