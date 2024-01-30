import SwiftUI
import RealityKit

struct ContentView: View {
    @State private var rootEntity: Entity = .init()
    @State private var selected: Index?
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        RealityView { content, attachments in
            self.rootEntity.position.y = 1.2
            self.rootEntity.position.z = -0.6
            GameState.preset.forEach { (key: Index, value: Piece) in
                let entity = try! Entity.load(named: value.assetName)
                entity.position = key.position
                entity.components.set([
                    HoverEffectComponent(),
                    InputTargetComponent(),
                    CollisionComponent(
                        shapes: [.generateBox(size: entity.visualBounds(relativeTo: nil).extents)]
                    ),
                    PieceStateComponent(index: key)
                ])
                self.rootEntity.addChild(entity)
            }
            self.rootEntity.addChild(attachments.entity(for: "board")!)
            content.add(self.rootEntity)
        } attachments: {
            Attachment(id: "board") { BoardView() }
        }
        .gesture(
            TapGesture()
                .targetedToEntity(where: .has(PieceStateComponent.self))
                .onEnded { value in
                    let state = value.entity.components[PieceStateComponent.self]!
                    value.entity.move(to: .init(translation: .init(x: 0,
                                                                   y: state.selected ? -0.1 : 0.1,
                                                                   z: 0)),
                                      relativeTo: value.entity,
                                      duration: 1)
                    value.entity.components[PieceStateComponent.self]!.selected.toggle()
                }
        )
    }
}
