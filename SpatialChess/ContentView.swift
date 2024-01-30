import SwiftUI
import RealityKit

struct ContentView: View {
    @State private var rootEntity: Entity = .init()
    @State private var selected: Index?
    var body: some View {
        RealityView { content in
            self.rootEntity.position.y = 1.2
            self.rootEntity.position.z = -1
            GameState.preset.forEach { (key: Index, value: Piece) in
                let entity = try! Entity.load(named: value.assetName)
                entity.position = key.position
                entity.generateCollisionShapes(recursive: true)
                entity.components.set([HoverEffectComponent(),
                                       InputTargetComponent()])
                self.rootEntity.addChild(entity)
            }
            content.add(self.rootEntity)
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    value.entity.move(to: .init(translation: .init(x: 0, y: 10, z: 0)),
                                      relativeTo: value.entity,
                                      duration: 1)
                }
        )
    }
}
