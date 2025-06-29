import SwiftUI

struct AboutAppLink: View {
    var body: some View {
        NavigationLink {
            List { ℹ️AboutAppContent() }
        } label: {
            Text("About App")
        }
    }
}
