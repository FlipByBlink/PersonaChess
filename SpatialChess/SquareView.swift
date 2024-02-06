import SwiftUI

struct SquareView: View {
    @EnvironmentObject var model: AppModel
    private var row: Int
    private var column: Int
    @State private var inputtable: Bool = false
    var body: some View {
        Group {
            if (self.column + self.row) % 2 == 1 {
                Rectangle()
                    .fill(.background)
            } else {
                Color.clear
                    .glassBackgroundEffect(in: .rect)
            }
        }
        .contentShape(.rect)
        .hoverEffect(isEnabled: self.inputtable)
        .onTapGesture {
            if self.inputtable {
                self.model.applyLatestAction(.tapSquare(.init(self.row, self.column)))
                self.model.sendMessage()
            }
        }
        .onChange(of: self.model.gameState) { self.updateInputtable() }
    }
    init(_ row: Int, _ column: Int) {
        self.row = row
        self.column = column
    }
}

private extension SquareView {
    private func updateInputtable() {
        let latestActivePiecesSituation = self.model.gameState.latestSituation.filter { !$0.removed }
        if latestActivePiecesSituation.contains(where: { $0.picked }),
           !latestActivePiecesSituation.contains(where: { $0.index == .init(self.row, self.column) }) {
            self.inputtable = true
        } else {
            self.inputtable = false
        }
    }
}
