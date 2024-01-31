import SwiftUI
import RealityKit

struct ContentView: View {
    @StateObject var model: AppModel = .init()
    var body: some View {
        RealityView { content, attachments in
            self.model.setUpEntities()
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
