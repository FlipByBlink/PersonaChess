import SwiftUI

struct AboutAppLink: View {
    var body: some View {
        NavigationLink {
            List { ℹ️AboutAppContent() }
        } label: {
            Label("About App", systemImage: "info")
                .padding(14)
        }
        .buttonBorderShape(.circle)
        .buttonStyle(.plain)
    }
}
