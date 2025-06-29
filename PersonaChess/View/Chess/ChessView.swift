import SwiftUI
import RealityKit

struct ChessView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    @Environment(\.sceneKind) var sceneKind
    
    @State private var dragState: DragState?
    
    var body: some View {
        RealityView { content, attachments in
            attachments.entity(for: "board")!.name = "board"
            content.add(attachments.entity(for: "board")!)
            content.add(self.model.entities.root)
        } update: { content, _ in
            if self.sceneKind == .window,
               !self.model.isImmersiveSpaceShown {
                content.add(self.model.entities.root)
            }
        } attachments: {
            Attachment(id: "board") {
                BoardView()
            }
        }
        .gesture(ExclusiveGesture(self.dragGesture, self.tapGesture))
        .modifier(Self.BoardRotation())
        .frame(width: Size.Point.board(self.physicalMetrics), height: 0)
        .frame(depth: Size.Point.board(self.physicalMetrics))
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
                let newDragState: DragState
                if let dragState {
                    newDragState = dragState.updating(dragTranslation)
                } else {
                    let sourceIndex = self.model.sharedState.pieces.indices[draggedPiece]!
                    newDragState = DragState(draggedPiece,
                                             sourceIndex,
                                             dragTranslation)
                }
                self.dragState = newDragState
                self.model.handle(.drag(newDragState))
            }
            .onEnded {
                let droppedPiece = $0.entity.parent!.components[Piece.self]!
                let dragTranslation = $0.convert($0.translation3D,
                                                 from: .local,
                                                 to: self.model.entities.root)
                let sourceIndex = self.model.sharedState.pieces.indices[droppedPiece]!
                self.model.handle(.drop(DragState(droppedPiece,
                                                  sourceIndex,
                                                  dragTranslation)))
                self.dragState = nil
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
    private struct BoardRotation: ViewModifier {
        @EnvironmentObject var model: AppModel
        @Environment(\.sceneKind) var sceneKind
        private var angle: Double {
            switch self.sceneKind {
                case .window:
                    self.model.isImmersiveSpaceShown ? 0 : self.model.sharedState.boardAngle
                case .immersiveSpace:
                    self.model.isImmersiveSpaceShown ? self.model.sharedState.boardAngle : 0
            }
        }
        func body(content: Content) -> some View {
            content.rotation3DEffect(.degrees(self.angle), axis: .y)
        }
    }
}




//↓ This causes a delay before the drag is recognized.
//.gesture(ExclusiveGesture(self.tapGesture, self.dragGesture))

//↓ This results in both inputs being fired, making it harder to manage.
//.gesture(SimultaneousGesture(self.dragGesture, self.tapGesture))
