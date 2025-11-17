import SwiftUI

struct WhatsSharePlayMenu: View {
    var body: some View {
        List {
            Section {
                Image(.exampleSharePlay)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                    .clipShape(.rect(cornerRadius: 10))
                    .listRowBackground(Color.clear)
                    .frame(maxWidth: .infinity)
            }
            Section {
                Text("With SharePlay in the FaceTime app, you can play chess in sync with friends and family while on a FaceTime call together. Enjoy a real-time connection with others on the call—with synced game and shared controls, you see and hear the same moments at the same time.")
                Text("In visionOS 26, You can share spatial experiences with other Apple Vision Pro users in the same room.")
            }
            Self.linkSection(
                url: "https://support.apple.com/guide/apple-vision-pro/tan15b2c7bf9/visionos",
                title: #"“Use SharePlay in FaceTime calls on Apple Vision Pro - Apple Support”"#
            )
            Self.linkSection(
                url: "https://support.apple.com/guide/apple-vision-pro/tanbccb085c1/visionos",
                title: #"“Share apps and experiences with people nearby on Apple Vision Pro - Apple Support”"#,
                hasHeader: false
            )
            Section {
                Text("The Group Activities framework uses end-to-end encryption on all session data. Developer and Apple doesn’t have the keys to decrypt this data.")
            } header: {
                Text("About data")
            }
        }
        .navigationTitle("What's SharePlay?")
    }
}

private extension WhatsSharePlayMenu {
    private static func linkSection(url: String,
                                    title: LocalizedStringResource,
                                    hasHeader: Bool = true) -> some View {
        Section {
            Link(destination: URL(string: url)!) {
                Text(title)
            }
            .foregroundStyle(.link)
        } header: {
            Text("Apple official support page")
        } footer: {
            Text(verbatim: "\(url)")
        }
    }
}
