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
                    Text(#""Use spatial Persona (beta) on Apple Vision Pro - Apple Support”"#)
                }
                .foregroundStyle(.link)
            } header: {
                Text("Apple official support page")
            } footer: {
                Text(verbatim: "\(url1)")
            }
            let url2 = URL(string: "https://support.apple.com/guide/apple-vision-pro/capture-your-persona-beta-dev934d40a17/1.0/visionos/1.0")!
            Section {
                Link(destination: url2) {
                    Text(#"“Capture and edit your Persona (beta) on Apple Vision Pro - Apple Support”"#)
                }
                .foregroundStyle(.link)
            } footer: {
                Text(verbatim: "\(url2)")
            }
            Text("The Persona (or Spatial Persona) is displayed as part of SharePlay, in collaboration with this app and FaceTime.")
        }
        .navigationTitle("What's Persona?")
    }
}
