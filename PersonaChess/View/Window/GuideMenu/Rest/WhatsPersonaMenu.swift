import SwiftUI

struct WhatsPersonaMenu: View {
    var body: some View {
        List {
            Section {
                Image(.exampleSpatialPersonas)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                    .clipShape(.rect(cornerRadius: 10))
                    .listRowBackground(Color.clear)
                    .frame(maxWidth: .infinity)
            }
            let url1 = URL(string: "https://support.apple.com/guide/apple-vision-pro/use-spatial-persona-tana1ea03f18/visionos")!
            Section {
                Link(destination: url1) {
                    Text(#""Use spatial Persona on Apple Vision Pro - Apple Support”"#)
                }
                .foregroundStyle(.link)
            } header: {
                Text("Apple official support page")
            } footer: {
                Text(verbatim: "\(url1)")
            }
            let url2 = URL(string: "https://support.apple.com/guide/apple-vision-pro/dev934d40a17/visionos")!
            Section {
                Link(destination: url2) {
                    Text(#"“Capture and edit your Persona on Apple Vision Pro - Apple Support”"#)
                }
                .foregroundStyle(.link)
            } footer: {
                Text(verbatim: "\(url2)")
            }
            Text("The Persona is displayed as part of SharePlay, in collaboration with this app and FaceTime.")
        }
        .navigationTitle("What's Persona?")
    }
}
