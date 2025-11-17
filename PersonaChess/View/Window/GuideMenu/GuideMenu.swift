import SwiftUI

struct GuideMenu: ViewModifier {
    func body(content: Content) -> some View {
        content
            .ornament(attachmentAnchor: .scene(.bottomBack),
                      contentAlignment: .bottom) {
                GuideMenuView()
            }
    }
}
