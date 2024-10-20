import SwiftUI

struct SquareView_2DMode: View {
    @EnvironmentObject var model: AppModel
    var row: Int
    var column: Int
    @State private var inputtable: Bool = false
    
    var body: some View {
        Group {
            if (self.column + self.row) % 2 == 1 {
                Rectangle()
                    .fill(.background)
            } else {
                Rectangle()
                    .opacity(0.001)
            }
        }
        .contentShape(.rect)
        .hoverEffect(isEnabled: self.inputtable)
        .onTapGesture {
            if self.inputtable {
                self.model.handle(.tapSquare(.init(self.row, self.column)))
            }
        }
        .onChange(of: self.model.sharedState.pieces) { self.updateInputtable() }
        .frame(width: Size.Point.squareSize_2DMode,
               height: Size.Point.squareSize_2DMode)
    }
}

private extension SquareView_2DMode {
    private func updateInputtable() {
        let myIndex = Index(self.row, self.column)
        if self.model.sharedState.pieces.isPicking {
            if !self.model.sharedState.pieces.indices.values.contains(myIndex) {
                self.inputtable = true
            } else {
                self.inputtable = (self.model.sharedState.pieces.pickingPieceIndex! == myIndex)
            }
        } else {
            self.inputtable = false
        }
    }
}
