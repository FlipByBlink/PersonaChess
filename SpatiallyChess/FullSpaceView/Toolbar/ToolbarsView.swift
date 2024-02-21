import SwiftUI

struct ToolbarsView: View {
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        ZStack {
            ForEach(ToolbarPosition.allCases) {
                ToolbarView(position: $0)
            }
        }
        .offset(z: Size.Point.board(self.physicalMetrics) / 2)
    }
}
