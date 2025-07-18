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
            }
            let url = URL(string: "https://support.apple.com/guide/apple-vision-pro/use-shareplay-in-facetime-calls-tan15b2c7bf9/1.0/visionos/1.0")!
            Section {
                Link(destination: url) {
                    Text(#"“Use SharePlay in FaceTime calls on Apple Vision Pro - Apple Support”"#)
                }
                .foregroundStyle(.link)
            } header: {
                Text("Apple official support page")
            } footer: {
                Text(verbatim: "\(url)")
            }
            Section {
                Text("The Group Activities framework uses end-to-end encryption on all session data. Developer and Apple doesn’t have the keys to decrypt this data.")
            } header: {
                Text("About data")
            }
        }
        .navigationTitle("What's SharePlay?")
    }
}
