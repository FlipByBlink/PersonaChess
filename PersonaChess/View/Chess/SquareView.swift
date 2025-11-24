import SwiftUI

struct SquareView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.sceneKind) var sceneKind
    private var row: Int
    private var column: Int
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
        .disabled(!self.model.sharedState.pieces.isPicking)
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
    private struct SquareButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
        }
    }
}
