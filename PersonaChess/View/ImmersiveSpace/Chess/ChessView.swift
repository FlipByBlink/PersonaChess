import SwiftUI
import RealityKit

struct ChessView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        RealityView { content, attachments in
            attachments.entity(for: "board")!.name = "board"
            self.model.entities.root.addChild(attachments.entity(for: "board")!)
            content.add(self.model.entities.root)
        } attachments: {
            Attachment(id: "board") {
                BoardView()
                    .environmentObject(self.model)
            }
        }
        //.gesture(ExclusiveGesture(self.tapGesture, self.dragGesture)) これだとdrag判定開始までラグが発生する。
        //.gesture(SimultaneousGesture(self.dragGesture, self.tapGesture)) これだとどちらも入力があって複雑になる。
        .gesture(ExclusiveGesture(self.dragGesture, self.tapGesture))
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
    private var dragGesture: some Gesture {
        DragGesture()
            .targetedToAnyEntity()
            .handActivationBehavior(.pinch)
            .onChanged {
                let draggedPiece = $0.entity.parent!.components[Piece.self]!
                let dragTranslation = $0.convert($0.translation3D,
                                                 from: .local,
                                                 to: self.model.entities.root)
                self.model.handle(.drag(draggedPiece,
                                        translation: dragTranslation))
            }
            .onEnded {
                let droppedPiece = $0.entity.parent!.components[Piece.self]!
                let dragTranslation = $0.convert($0.translation3D,
                                                 from: .local,
                                                 to: self.model.entities.root)
                self.model.handle(.drop(droppedPiece,
                                        dragTranslation: dragTranslation))
            }
    }
    private var tapGesture: some Gesture {
        TapGesture()
            .targetedToAnyEntity()
            .onEnded {
                guard let tappedPiece = $0.entity.parent?.components[Piece.self] else {
                    assertionFailure()
                    return
                }
                self.model.handle(.tapPiece(tappedPiece))
            }
    }
}
