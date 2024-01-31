import SwiftUI
import RealityKit

struct ContentView: View {
    @StateObject var model: AppModel = .init()
    var body: some View {
        RealityView { content, attachments in
            self.model.rootEntity.position.y = 1.2
            self.model.rootEntity.position.z = -0.6
            self.model.gameState.previousSituation = FixedValue.preset
            self.model.gameState.previousSituation.forEach { pieceState in
                let entity = try! Entity.load(named: pieceState.assetName)
                entity.name = pieceState.id.uuidString
                entity.components.set([
                    HoverEffectComponent(),
                    InputTargetComponent(),
                    OpacityComponent(),
                    CollisionComponent(
                        shapes: [.generateBox(size: entity.visualBounds(relativeTo: nil).extents)]
                    ),
                    pieceState
                ])
                self.model.rootEntity.addChild(entity)
            }
            self.model.updatePosition()
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
                .onEnded {
                    let action: Action = .tapPiece(.init(uuidString: $0.entity.name)!)
                    self.model.updateGameState(with: action)
                    self.model.applyLatestAction(action)
                    self.model.sendMessage()
                }
        )
    }
}
