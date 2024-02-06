import SwiftUI
import RealityKit

struct 🌐RealityView: View {
    @EnvironmentObject var model: 🥽AppModel
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
                .targetedToAnyEntity()
                .onEnded { self.model.executeAction(.tapPiece($0.entity)) }
        )
    }
}
