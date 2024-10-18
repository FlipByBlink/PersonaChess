import SwiftUI

struct OpenMenuButton: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        Menu {
            Group {
                Button {
                    self.model.execute(.undo)
                } label: {
                    Label("Undo", systemImage: "arrow.uturn.backward")
                }
                .disabled(self.model.sharedState.logs.isEmpty)
                Button {
                    self.model.execute(.reset)
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
                .disabled(self.model.sharedState.pieces.isPreset)
            }
            .disabled(self.model.isAnimating)
        } label: {
            Text("Menu")
                .padding(12)
                .padding(.horizontal, 2)
                .frame(minHeight: 42)
        } primaryAction: {
            self.model.isMenuSheetShown = true
        }
        .glassBackgroundEffect()
        .disabled(self.model.isMenuSheetShown)
    }
}
