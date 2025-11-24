import SwiftUI

struct AboutOptionsMenuLink: View {
    var body: some View {
        Section {
            NavigationLink("About options") {
                Self.ContentView()
            }
        }
    }
}

private extension AboutOptionsMenuLink {
    private struct ContentView: View {
        @EnvironmentObject var model: AppModel
        var body: some View {
            List {
                Section {
                    Label("The Remove feature allows you to remove a picking piece. You can also remove a piece by dropping it outside the board.",
                          systemImage: "delete.left")
                    Label("The Undo feature allows you to take back your last move.",
                          systemImage: "arrow.uturn.backward")
                    Label("The Reset feature allows you to restart the chess game from the beginning.",
                          systemImage: "arrow.counterclockwise")
                }
                
                Section {
                    VStack(alignment: .leading) {
                        Label("Adjust the size of the board on the ground.",
                              systemImage: "arrow.up.left.and.arrow.down.right")
                        Image(.immersiveSpaceMode)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 360)
                            .clipShape(.rect(cornerRadius: 6))
                            .padding()
                    }
                } header: {
                    Text("Ground mode")
                }
            }
            .navigationTitle("About options")
        }
    }
}
