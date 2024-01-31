import SwiftUI

struct SquareView: View {
    @EnvironmentObject var model: AppModel
    private var row: Int
    private var column: Int
    @State private var inputtable: Bool = false
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
                let action: Action = .tapSquare(.init(self.row, self.column))
                self.model.updateGameState(with: action)
                self.model.applyLatestAction(action)
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
        let latestSituation = self.model.getLatestSituation()
        if latestSituation.contains(where: { $0.picked }),
           !latestSituation.contains(where: { $0.index == .init(row, column) }) {
            self.inputtable = true
        } else {
            self.inputtable = false
        }
    }
}
