import SwiftUI
import RealityKit

struct ContentView: View {
    var body: some View {
        RealityView { content in
            GameState.preset.forEach { (key: GameState.Position, value: Piece) in
                let entity = try! Entity.load(named: value.assetName)
                entity.position = key.position
                content.add(entity)
            }
        }
    }
}
