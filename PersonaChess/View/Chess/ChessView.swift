import SwiftUI
import RealityKit

struct ChessView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
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
        .frame(width: Size.Point.board(self.physicalMetrics), height: 0)
        .frame(depth: Size.Point.board(self.physicalMetrics))
        .overlay {
            if self.model.showProgressView {
                ProgressView()
                    .offset(y: -200)
                    .scaleEffect(3)
            }
        }
        .rotation3DEffect(.init(angle: .degrees(270), axis: .y))
    }
}
