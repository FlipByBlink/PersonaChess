import SwiftUI

struct OpenGuideMenuButton: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.isEnabled) var isEnabled
    var body: some View {
        if self.model.groupSession == nil {
            Divider()
                .padding(.vertical, 2)
            Button {
                self.model.isGuideMenuShown.toggle()
            } label: {
                Text("Open menu")
                    .frame(height: 40)
                    .padding(.horizontal, 8)
                    .opacity(self.isEnabled ? 1.0 : 0.4)
                    .animation(.default.speed(0.7), value: self.isEnabled)
            }
            .disabled(self.model.isGuideMenuShown)
            .buttonStyle(.plain)
        }
    }
}
