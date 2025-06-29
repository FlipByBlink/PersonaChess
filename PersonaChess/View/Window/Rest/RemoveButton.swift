import SwiftUI

struct RemoveButton: View {
    @EnvironmentObject var model: AppModel
    
    var body: some View {
        Button("remove", systemImage: "delete.left") {
            if let pickedPiece = self.model.sharedState.pieces.pickingPiece {
                self.model.execute(.remove(pickedPiece))
            }
        }
        .disabled(self.model.sharedState.pieces.pickingPiece == nil)
        .disabled(self.model.isAnimating)
    }
}
