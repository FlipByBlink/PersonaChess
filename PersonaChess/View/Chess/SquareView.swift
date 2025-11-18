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
                        UnevenRoundedRectangle(cornerRadii: self.radii)
                            .fill(.black.tertiary)
                    case .window:
                        UnevenRoundedRectangle(cornerRadii: self.radii)
                            .fill(.background)
                }
            } else {
                UnevenRoundedRectangle(cornerRadii: self.radii)
                    .opacity(0.001)
            }
        }
        .glassBackgroundEffect(in: .rect(cornerRadii: self.radii))
        .contentShape(.hoverEffect, .rect(cornerRadii: self.radii))
        .hoverEffect(isEnabled: self.inputtable)
        .onTapGesture {
            if self.inputtable {
                self.model.handle(.tapSquare(.init(self.row, self.column)))
            }
        }
        .allowsHitTesting(self.inputtable)
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
