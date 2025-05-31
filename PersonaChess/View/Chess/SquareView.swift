import SwiftUI

struct SquareView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.sceneKind) var sceneKind
    private var row: Int
    private var column: Int
    @State private var inputtable: Bool = false
    var body: some View {
        Group {
            if (self.column + self.row) % 2 == 1 {
                switch self.sceneKind {
                    case .immersiveSpace:
                        Rectangle()
                            .fill(.black.tertiary)
                    case .volume:
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
