import SwiftUI
import RealityKit

struct ContentView: View {
    @StateObject var model: AppModel = .init()
    var body: some View {
        RealityView { content, attachments in
            self.model.setUpEntities()
            self.model.rootEntity.addChild(attachments.entity(for: "board")!)
            self.model.rootEntity.addChild(attachments.entity(for: "toolbar")!)
            content.add(self.model.rootEntity)
        } attachments: {
            Attachment(id: "board") {
                BoardView()
                    .environmentObject(self.model)
            }
            Attachment(id: "toolbar") {
                ToolbarView()
                    .environmentObject(self.model)
            }
        }
        .gesture(
            TapGesture()
                .targetedToEntity(where: .has(PieceStateComponent.self))
                .onEnded {
                    self.model.applyLatestAction(.tapPiece($0.entity.components[PieceStateComponent.self]!.id))
                }
        )
        .task { 📢SoundEffect.setCategory() }
    }
}
