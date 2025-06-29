import SwiftUI
import RealityKit

struct ChessView_iOS: View {
    @EnvironmentObject var model: AppModel
    
    @State private var dragState: DragState?
    
    @State private var isCameraEnabled = true
    
    var body: some View {
        RealityView { content in
            content.add(self.model.entities.root)
            content.cameraTarget = self.model.entities.root
        }
        .gesture(ExclusiveGesture(self.dragGesture, self.tapGesture))
        .realityViewCameraControls(self.isCameraEnabled ? .orbit : .none)
        .overlay {
            if self.model.isSharedStateInvalidInSharePlay { ProgressView() }
        }
        .overlay(alignment: .bottomTrailing) { self.cameraControlToggle() }
    }
}

private extension ChessView_iOS {
    private var dragGesture: some Gesture {
        DragGesture()
            .targetedToEntity(where: .has(HoverEffectComponent.self))
            .onChanged {
                guard let draggedPiece = $0.entity.parent?.components[Piece.self] else {
                    return
                }
                
                let sourceIndex = self.model.sharedState.pieces.indices[draggedPiece]!
                let sourcePositionEntity = Entity()
                sourcePositionEntity.setPosition(sourceIndex.position,
                                                 relativeTo: self.model.entities.root)
                let dragTranslation = $0.unproject($0.location,
                                                   from: .local,
                                                   to: sourcePositionEntity)!
                
                let newDragState: DragState
                if let dragState {
                    newDragState = dragState.updating(dragTranslation)
                } else {
                    newDragState = DragState(draggedPiece,
                                             sourceIndex,
                                             dragTranslation)
                }
                self.dragState = newDragState
                self.model.handle(.drag(newDragState))
            }
            .onEnded {
                guard let droppedPiece = $0.entity.parent?.components[Piece.self] else {
                    return
                }
                
                let sourceIndex = self.model.sharedState.pieces.indices[droppedPiece]!
                let sourcePositionEntity = Entity()
                sourcePositionEntity.setPosition(sourceIndex.position,
                                                 relativeTo: self.model.entities.root)
                let dragTranslation = $0.unproject($0.location,
                                                   from: .local,
                                                   to: sourcePositionEntity)!
                
                self.model.handle(.drop(DragState(droppedPiece,
                                                  sourceIndex,
                                                  dragTranslation)))
                self.dragState = nil
            }
    }
    private var tapGesture: some Gesture {
        TapGesture()
            .targetedToEntity(where: .has(HoverEffectComponent.self))
            .onEnded {
                guard let tappedPiece = $0.entity.parent?.components[Piece.self] else {
                    assertionFailure()
                    return
                }
                self.model.handle(.tapPiece(tappedPiece))
            }
    }
    private func cameraControlToggle() -> some View {
        Toggle(isOn: self.$isCameraEnabled) {
            HStack {
                Spacer()
                Text("Camera control")
            }
        }
        .foregroundStyle(.secondary)
        .font(.caption.weight(.medium))
        .padding(.trailing)
    }
}
