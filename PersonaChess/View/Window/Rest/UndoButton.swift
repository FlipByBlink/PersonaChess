import SwiftUI

struct UndoButton: View {
    @EnvironmentObject var model: AppModel
    
    var body: some View {
        Button {
            self.model.execute(.undo)
        } label: {
            Label("Undo", systemImage: "arrow.uturn.backward")
        }
        .disabled(self.model.sharedState.logs.isEmpty)
        .disabled(self.model.isAnimating)
    }
}
