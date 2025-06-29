import SwiftUI

struct AboutOptionsMenu: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        List {
            Section {
                Label("The Undo feature allows you to take back your last move.",
                      systemImage: "arrow.uturn.backward")
                Label("The Reset feature allows you to restart the chess game from the beginning.",
                      systemImage: "arrow.counterclockwise")
            }
            
            Section {
                Label("Adjust the size of the board.",
                      systemImage: "plusminus")
                Image(.floorModeExample)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 360)
                    .clipShape(.rect(cornerRadius: 6))
                    .padding()
            } header: {
                Text("Immersive space mode")
            }
        }
        .navigationTitle("About options")
    }
}
