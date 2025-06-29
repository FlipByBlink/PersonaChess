import SwiftUI

struct BottomButtons: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomOrnament) {
            HStack(spacing: 12) {
                OpenAndDismiss3DSpaceButton()
                RotateBoardButton()
                RemoveButton()
                UndoButton()
                ResetButton()
                OpenGuideMenuButton()
            }
            .buttonStyle(Self.Style())
            .padding(.horizontal, 8)
        }
    }
}

private extension BottomButtons {
    private struct Style: ButtonStyle {
        @Environment(\.isEnabled) var isEnabled
        func makeBody(configuration: Configuration) -> some View {
            configuration
                .label
                .frame(width: 42, height: 42)
                .opacity(self.isEnabled ? 1.0 : 0.4)
                .animation(.default.speed(0.7), value: self.isEnabled)
                .contentShape(.circle)
                .hoverEffect()
        }
    }
}
