import SwiftUI

struct BottomButtons: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomOrnament) {
            Group {
                OpenAndDismiss3DSpaceButton()
                    .padding(.leading, 8)
                RotateBoardButton()
                RemoveButton()
                UndoButton()
                ResetButton()
                OpenGuideMenuButton()
                    .padding(.trailing, 8)
            }
            .buttonStyle(Self.Style())
        }
    }
}

private extension BottomButtons {
    private struct Style: ButtonStyle {
        @Environment(\.isEnabled) var isEnabled
        func makeBody(configuration: Configuration) -> some View {
            configuration
                .label
                .padding(9)
                .opacity(self.isEnabled ? 1.0 : 0.4)
                .animation(.default.speed(0.7), value: self.isEnabled)
                .contentShape(.circle)
                .hoverEffect()
        }
    }
}
