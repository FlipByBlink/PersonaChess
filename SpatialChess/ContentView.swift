import SwiftUI
import RealityKit

struct ContentView: View {
    @StateObject var model: AppModel = .init()
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        RealityView { content, attachments in
            self.model.rootEntity.position.y = 1.2
            self.model.rootEntity.position.z = -0.6
            self.model.gameState.value.forEach { (key: Index, value: Piece) in
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
                self.model.rootEntity.addChild(entity)
            }
            self.model.rootEntity.addChild(attachments.entity(for: "board")!)
            content.add(self.model.rootEntity)
        } attachments: {
            Attachment(id: "board") {
                BoardView()
                    .environmentObject(self.model)
            }
        }
        .gesture(
            TapGesture()
                .targetedToEntity(where: .has(PieceStateComponent.self))
                .onEnded { value in
                    let state = value.entity.components[PieceStateComponent.self]!
                    value.entity.move(to: .init(translation: .init(x: 0,
                                                                   y: state.picked ? -0.1 : 0.1,
                                                                   z: 0)),
                                      relativeTo: value.entity,
                                      duration: 1)
                    value.entity.components[PieceStateComponent.self]!.picked.toggle()
                }
        )
    }
}
