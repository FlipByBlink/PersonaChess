import SwiftUI

struct OpenAndDismissImmersiveSpaceButton: View {
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
            Label(
                self.title,
                systemImage: {
                    if self.model.isImmersiveSpaceShown {
                        "arrow.up.forward.and.arrow.down.backward"
                    } else {
                        "arrow.up.left.and.arrow.down.right"
                    }
                }()
            )
        }
        .help(self.title)
        .animation(.default, value: self.model.isImmersiveSpaceShown)
//#if DEBUG
//        .task { await self.openImmersiveSpace(id: "immersiveSpace") }
//#endif
    }
}

private extension OpenAndDismissImmersiveSpaceButton {
    private var title: LocalizedStringResource {
        self.model.isImmersiveSpaceShown ? "Dismiss immersive space" : "Open immersive space"
    }
}
