import SwiftUI

struct SquareView: View {
    @EnvironmentObject var model: AppModel
    private var row: Int
    private var column: Int
    @State private var inputtable: Bool = false
    var body: some View {
        Group {
            if (self.column + self.row) % 2 == 1 {
                if self.model.floorMode {
                    Rectangle()
                        .fill(.black.tertiary)
                } else {
                    Rectangle()
                        .fill(.background)
                }
            } else {
                Rectangle()
                    .opacity(0.001)
            }
        }
        .hoverEffect(isEnabled: self.inputtable)
        .onTapGesture {
            if self.inputtable {
                self.model.handle(.tapSquare(.init(self.row, self.column)))
            }
        }
        .onChange(of: self.model.sharedState.pieces) { self.updateInputtable() }
        .task { self.updateInputtable() }
    }
    init(_ row: Int, _ column: Int) {
        self.row = row
        self.column = column
    }
}

private extension SquareView {
    private func updateInputtable() {
        let activePieces = self.model.sharedState.pieces.activeOnly
        let myIndex = Index(self.row, self.column)
        if activePieces.contains(where: { $0.picked }) {
            if !activePieces.contains(where: { $0.index == myIndex }) {
                self.inputtable = true
            } else {
                guard let pickedPiece = activePieces.first(where: { $0.picked }) else {
                    assertionFailure()
                    return
                }
                self.inputtable = (pickedPiece.index == myIndex)
            }
        } else {
            self.inputtable = false
        }
    }
}
