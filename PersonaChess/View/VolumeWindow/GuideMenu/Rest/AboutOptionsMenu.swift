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
                HStack(spacing: 16) {
                    Label("Open the toolbar on your left wrist.",
                          systemImage: "line.horizontal.3")
                    Spacer()
                    Image(.toolbarHand)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 320)
                        .clipShape(.rect(cornerRadius: 6))
                }
                .padding()
                Label("Adjust the size of the board.",
                      systemImage: "plusminus")
                Image(.floorModeExample)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 360)
                    .clipShape(.rect(cornerRadius: 6))
                    .padding()
            } header: {
                Text("Full space mode")
            }
        }
        .navigationTitle("About options")
    }
}
