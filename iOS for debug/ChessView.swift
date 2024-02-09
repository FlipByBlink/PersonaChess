import SwiftUI
import RealityKit

struct ChessView: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        Text("ChessView")
            .onTapGesture {
                self.model.execute(.tapPiece(Entity()))
            }
            .rotationEffect(.degrees(self.model.activityState.boardAngle))
            .animation(.default, value: self.model.activityState.boardAngle)
    }
}
