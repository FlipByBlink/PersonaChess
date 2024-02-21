import SwiftUI
import RealityKit

struct ChessView: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        RealityView { content, attachments in
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
                .onEnded { self.model.execute(.tapPiece($0.entity)) }
        )
        .rotation3DEffect(.degrees(self.model.activityState.boardAngle), axis: .y)
        .animation(.default, value: self.model.activityState.boardAngle)
        .frame(width: FixedValue.boardSize, height: FixedValue.boardSize)
        .frame(depth: FixedValue.boardSize)
        .overlay {
            if self.model.showProgressView {
                ProgressView()
                    .offset(y: -200)
                    .scaleEffect(3)
            }
        }
    }
}
