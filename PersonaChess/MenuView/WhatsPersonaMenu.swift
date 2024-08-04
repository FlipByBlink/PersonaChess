import SwiftUI

struct WhatsPersonaMenu: View {
    var body: some View {
        List {
            Text("The Persona (or Spatial Persona) is displayed as part of SharePlay, in collaboration with this app and FaceTime.")
            let url1 = URL(string: "https://support.apple.com/guide/apple-vision-pro/use-spatial-persona-tana1ea03f18/visionos")!
            Section {
                Link(destination: url1) {
                    Text(verbatim: #""Use spatial Persona (beta) on Apple Vision Pro - Apple Support”"#)
                }
            } header: {
                Text("Apple official support page")
            } footer: {
                Text(verbatim: "\(url1)")
            }
            let url2 = URL(string: "https://support.apple.com/guide/apple-vision-pro/capture-your-persona-beta-dev934d40a17/1.0/visionos/1.0")!
            Section {
                Link(destination: url2) {
                    Text(verbatim: #"“Capture and edit your Persona (beta) on Apple Vision Pro - Apple Support”"#)
                }
            } footer: {
                Text(verbatim: "\(url2)")
            }
        }
        .navigationTitle("What's Persona?")
    }
}
