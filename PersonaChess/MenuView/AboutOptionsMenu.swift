import SwiftUI

struct AboutOptionsMenu: View {
    var body: some View {
        List {
            Section {
                HStack(spacing: 24) {
                    Label("Open the toolbar at the bottom of a board.",
                          systemImage: "ellipsis")
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 360)
                        .clipShape(.rect(cornerRadius: 6))
                }
                .padding()
                HStack(spacing: 24) {
                    Label("Open the toolbar on your left wrist.",
                          systemImage: "line.horizontal.3")
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 360)
                        .clipShape(.rect(cornerRadius: 6))
                }
                .padding()
            }
            Section {
                Label("Adjust the rotation of the board.",
                      systemImage: "arrow.turn.right.up")
                Label("Adjust the size of the board.",
                      systemImage: "plusminus")
                Label("Adjust the height of the board.",
                      systemImage: "chevron.up.chevron.down")
            }
            Section {
                Label("The Undo feature allows you to take back your last move.",
                      systemImage: "arrow.uturn.backward")
                Label("The Reset feature allows you to restart the chess game from the beginning.",
                      systemImage: "arrow.counterclockwise")
            }
            Section {
                HStack(spacing: 24) {
                    Label("By setting the board’s height equal to the floor, the board will seamlessly integrate with the floor.",
                          systemImage: "arrow.down.to.line")
                    Image(.floorModeExample)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 360)
                        .clipShape(.rect(cornerRadius: 6))
                }
                .padding()
            }
        }
        .navigationTitle("About options")
    }
}
