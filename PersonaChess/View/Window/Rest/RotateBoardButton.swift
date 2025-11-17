import SwiftUI

struct RotateBoardButton: View {
    @EnvironmentObject var model: AppModel
    
    var body: some View {
        Button {
            self.model.rotateBoard()
        } label: {
            Label("Rotate", systemImage: "arrow.turn.right.up")
        }
        .help("Rotate")
    }
}
