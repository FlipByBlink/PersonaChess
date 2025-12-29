import SwiftUI

struct AboutAppLink: View {
    var body: some View {
        Section {
            NavigationLink {
                List { ℹ️AboutAppContent() }
            } label: {
                Text("About App")
            }
        }
    }
}
