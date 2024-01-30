import SwiftUI

struct SquareView: View {
    @EnvironmentObject var model: AppModel
    private var row: Int
    private var column: Int
    var body: some View {
        Group {
            if (self.column + self.row) % 2 == 0 {
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
            }
        }
    }
    init(_ row: Int, _ column: Int) {
        self.row = row
        self.column = column
    }
}

private extension SquareView {
    private var inputtable: Bool {
        self.model.gameState.latestSituation.contains { $0.picked }
        &&
        !self.model.gameState.latestSituation.contains { $0.index == .init(row, column) }
    }
}
