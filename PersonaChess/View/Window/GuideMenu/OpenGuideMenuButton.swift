import SwiftUI

struct OpenGuideMenuButton: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        if self.model.groupSession == nil {
            Button {
                self.model.isGuideMenuShown.toggle()
            } label: {
                Label("Open menu", systemImage: "line.3.horizontal")
            }
            .disabled(self.model.isGuideMenuShown)
        }
    }
}
