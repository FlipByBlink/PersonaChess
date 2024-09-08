import SwiftUI

struct OpenButton: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    var body: some View {
        Button {
            Task { await self.openImmersiveSpace(id: "immersiveSpace") }
        } label: {
            HStack {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .imageScale(.small)
                Text("Open")
            }
            .fontWeight(.bold)
        }
        .buttonStyle(.borderedProminent)
        .tint(.blue)
        .opacity(self.model.isFullSpaceShown ? 0 : 1)
        .animation(.default, value: self.model.isFullSpaceShown)
    }
}
