import SwiftUI

struct ResetButton: View {
    @EnvironmentObject var model: AppModel
    
    var kind: Self.Kind = .toolbar
    
    var body: some View {
        Button {
            self.model.execute(.reset)
        } label: {
            switch self.kind {
                case .toolbar:
                    Label("Reset", systemImage: "arrow.counterclockwise")
                case .hand:
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .labelStyle(.iconOnly)
                        .frame(width: ToolbarViewOnHand.ContentView.circleButtonSize,
                               height: ToolbarViewOnHand.ContentView.circleButtonSize)
            }
        }
        .disabled(self.model.sharedState.pieces.isPreset)
        .disabled(self.model.isAnimating)
    }
    
    enum Kind {
        case toolbar, hand
    }
}
