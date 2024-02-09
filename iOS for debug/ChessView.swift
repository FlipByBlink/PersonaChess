import SwiftUI
import RealityKit

struct ChessView: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<8, id: \.self) { column in
                VStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { row in
                        SquareView(row, column)
                    }
                }
            }
        }
        .mask(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(white: 0.75), lineWidth: 3)
        }
        .frame(width: 330, height: 330)
        .onTapGesture {
            self.model.execute(.tapPiece(Entity()))
        }
        .rotationEffect(.degrees(self.model.activityState.boardAngle))
        .animation(.default, value: self.model.activityState.boardAngle)
    }
}

struct SquareView: View {
    @EnvironmentObject var model: AppModel
    private var row: Int
    private var column: Int
    @State private var inputtable: Bool = false
    var body: some View {
        Group {
            if (self.column + self.row) % 2 == 1 {
                Rectangle()
                    .fill(.gray.secondary)
            } else {
                Color.clear
            }
        }
        .contentShape(.rect)
        .hoverEffect(isEnabled: self.inputtable)
        .onTapGesture {
            if self.inputtable {
                self.model.execute(.tapSquare(.init(self.row, self.column)))
            }
        }
        .onChange(of: self.model.activityState.chess) { self.updateInputtable() }
    }
    init(_ row: Int, _ column: Int) {
        self.row = row
        self.column = column
    }
    private func updateInputtable() {
        let latestActivePieces = self.model.activityState.chess.latest.filter { !$0.removed }
        if latestActivePieces.contains(where: { $0.picked }),
           !latestActivePieces.contains(where: { $0.index == .init(self.row, self.column) }) {
            self.inputtable = true
        } else {
            self.inputtable = false
        }
    }
}
