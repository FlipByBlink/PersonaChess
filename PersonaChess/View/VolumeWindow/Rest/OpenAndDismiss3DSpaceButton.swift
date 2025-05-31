import SwiftUI

struct OpenAndDismiss3DSpaceButton: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    var body: some View {
        Button {
            Task {
                if self.model.isImmersiveSpaceShown {
                    await self.dismissImmersiveSpace()
                } else {
                    await self.openImmersiveSpace(id: "immersiveSpace")
                }
            }
        } label: {
            HStack {
                Image(systemName: {
                    if self.model.isImmersiveSpaceShown {
                        "arrow.up.forward.and.arrow.down.backward"
                    } else {
                        "arrow.up.left.and.arrow.down.right"
                    }
                }())
                .imageScale(.small)
                Text(self.model.isImmersiveSpaceShown ? "Dismiss 3D space" : "Open 3D space")
            }
            .fontWeight(self.model.isImmersiveSpaceShown ? .regular : nil)
        }
        .animation(.default, value: self.model.isImmersiveSpaceShown)
//#if DEBUG
//        .task { await self.openImmersiveSpace(id: "immersiveSpace") }
//#endif
    }
}
