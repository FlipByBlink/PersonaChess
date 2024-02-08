import SwiftUI
import RealityKit

struct 🌐RealityView: View {
    @EnvironmentObject var model: 🥽AppModel
    var body: some View {
        VStack {
            RealityView { content, attachments in
                self.model.setUpEntities()
                attachments.entity(for: "board")!.name = "board"
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
                    .targetedToAnyEntity()
                    .onEnded { self.model.executeAction(.tapPiece($0.entity)) }
            )
            .rotation3DEffect(.degrees(self.model.boardAngle),
                              axis: .y)
            .animation(.default, value: self.model.boardAngle)
            .frame(width: FixedValue.boardSize, height: FixedValue.boardSize)
            .frame(depth: FixedValue.boardSize)
            ToolbarView()
                .environmentObject(self.model)
        }
        .offset(z: -1000)
        .offset(y: -1000 - self.model.viewHeight)
        .animation(.default, value: self.model.viewHeight)
    }
}
