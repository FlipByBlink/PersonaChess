import SwiftUI

struct SquareView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.sceneKind) var sceneKind
    private var row: Int
    private var column: Int
    @State private var inputtable: Bool = false
    var body: some View {
        Button {
            self.model.handle(.tapSquare(.init(self.row, self.column)))
        } label: {
            Group {
                if (self.column + self.row) % 2 == 1 {
                    switch self.sceneKind {
                        case .immersiveSpace:
                            UnevenRoundedRectangle(cornerRadii: self.radii)
                                .fill(.black.tertiary)
                        case .window:
                            UnevenRoundedRectangle(cornerRadii: self.radii)
                                .fill(.background)
                    }
                } else {
                    UnevenRoundedRectangle(cornerRadii: self.radii)
                        .opacity(0.01)
                }
            }
            .contentShape(.hoverEffect, .rect(cornerRadii: self.radii))
            .hoverEffect(.highlight)
        }
        .buttonStyle(Self.SquareButtonStyle())
        .disabled(!self.inputtable)
        .onChange(of: self.model.sharedState.pieces) { self.updateInputtable() }
        .task { self.updateInputtable() }
    }
    init(_ row: Int, _ column: Int) {
        self.row = row
        self.column = column
    }
}

private extension SquareView {
    private static var radius: CGFloat { 24 }
    private var radii: RectangleCornerRadii {
        let index = (self.row, self.column)
        return .init(
            topLeading: index == (0, 0) ? Self.radius : 0,
            bottomLeading: index == (7, 0) ? Self.radius : 0,
            bottomTrailing: index == (7, 7) ? Self.radius : 0,
            topTrailing: index == (0, 7) ? Self.radius : 0
        )
    }
    private func updateInputtable() {
        let myIndex = Index(self.row, self.column)
        self.inputtable = {
            guard let pickingPiece = self.model.sharedState.pieces.pickingPiece else {
                return false
            }
            if !self.model.sharedState.pieces.indices.values.contains(myIndex) {
                return true
            } else if myIndex == self.model.sharedState.pieces.pickingPieceIndex {
                return true
            } else {
                let myPieceSide = self.model.sharedState.pieces.piece(myIndex)?.side
                return (myPieceSide != pickingPiece.side)
            }
        }()
    }
    private struct SquareButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
        }
    }
}
