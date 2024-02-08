import SwiftUI

struct 🛠️ToolbarsView: View {
    var body: some View {
        ZStack {
            ForEach(🛠️ToolbarPosition.allCases) {
                🛠️ToolbarView(position: $0)
            }
        }
    }
}
