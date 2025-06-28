import SwiftUI

struct ResetButton: View {
    @EnvironmentObject var model: AppModel
    
    var body: some View {
        Button {
            self.model.execute(.reset)
        } label: {
            Label("Reset", systemImage: "arrow.counterclockwise")
        }
        .disabled(self.model.sharedState.pieces.isPreset)
        .disabled(self.model.isAnimating)
    }
}
