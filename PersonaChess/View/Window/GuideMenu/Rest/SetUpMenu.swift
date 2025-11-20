import SwiftUI
import GroupActivities

struct SetUpMenu: View {
    @EnvironmentObject var model: AppModel
    @StateObject private var groupStateObserver = GroupStateObserver()
    @SceneStorage("debugView") private var isDebugViewPresented: Bool = false
    var body: some View {
        List {
            Button {
                Task {
                    try? await AppGroupActivity().activate()
                }
            } label: {
                Label(#"Start "Share chess" activity"#, systemImage: "play.fill")
                    .fontWeight(.semibold)
            }
            .buttonStyle(.bordered)
            .listRowBackground(Color.clear)
            .frame(maxWidth: .infinity, alignment: .center)
            Section {
                VStack(spacing: 16) {
                    Text("You can start SharePlay from a system menu UI, which is located at the bottom of the app.")
                    Image(.bottomSystemUI)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                        .clipShape(.rect(cornerRadius: 16))
                }
            }
            Section {
                Text("If you launch this application during FaceTime, you can start an activity. When you start an activity, the callers automatically join an activity.")
            }
            Section {
                Text("If you want to join a SharePlay session that has already started, you can do so from the Control Center.")
            }
            Section {
                Text("If SharePlay doesn’t work properly, your app versions might be different. Please update the app to the latest version and try SharePlay again.")
            }
            Section {
                Text("Once SharePlay has begun, it is not possible to change the window height. Adjust it beforehand.")
                    .onTapGesture(count: 3) { self.isDebugViewPresented.toggle() }
            }
        }
        .navigationTitle("How to start")
    }
}
