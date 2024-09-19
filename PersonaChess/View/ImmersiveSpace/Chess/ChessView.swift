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
        //.gesture(ExclusiveGesture(self.tapGesture, self.dragGesture)) これだとdrag判定開始までラグが発生する。
        .gesture(SimultaneousGesture(self.tapGesture, self.dragGesture))
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

private extension ChessView {
    private var tapGesture: some Gesture {
        TapGesture()
            .targetedToAnyEntity()
            .onEnded { self.model.execute(.tapPiece($0.entity)) }
    }
    private var dragGesture: some Gesture {
        DragGesture()
            .targetedToAnyEntity()
            .handActivationBehavior(.pinch)
            .onChanged { value in
                let dragTranslation = value.convert(value.translation3D,
                                                    from: .local,
                                                    to: self.model.rootEntity)
                self.model.execute(.drag(value.entity,
                                         translation: dragTranslation))
            }
            .onEnded { value in
                self.model.execute(.drop(value.entity))
            }
    }
}
