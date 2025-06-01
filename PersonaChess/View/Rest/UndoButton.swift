import SwiftUI

struct UndoButton: View {
    @EnvironmentObject var model: AppModel
    
    var kind: Self.Kind = .toolbar
    
    var body: some View {
        Button {
            self.model.execute(.undo)
        } label: {
            switch self.kind {
                case .toolbar:
                    Label("Undo", systemImage: "arrow.uturn.backward")
                case .hand:
                    Label("Undo", systemImage: "arrow.uturn.backward")
                        .labelStyle(.iconOnly)
                        .frame(width: ToolbarViewOnHand.ContentView.circleButtonSize,
                               height: ToolbarViewOnHand.ContentView.circleButtonSize)
            }
        }
        .disabled(self.model.sharedState.logs.isEmpty)
        .disabled(self.model.isAnimating)
    }
    
    enum Kind {
        case toolbar, hand
    }
}
