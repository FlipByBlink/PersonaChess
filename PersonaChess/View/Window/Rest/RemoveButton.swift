import SwiftUI

struct RemoveButton: View {
    @EnvironmentObject var model: AppModel
    
    var body: some View {
        Button("Remove", systemImage: "delete.left") {
            if let pickedPiece = self.model.sharedState.pieces.pickingPiece {
                self.model.execute(.remove(pickedPiece))
            }
        }
        .help("Remove")
        .disabled(self.model.sharedState.pieces.pickingPiece == nil)
        .disabled(self.model.isAnimating)
    }
}
