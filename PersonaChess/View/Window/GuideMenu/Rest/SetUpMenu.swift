import SwiftUI
import GroupActivities

struct SetUpMenu: View {
    @EnvironmentObject var model: AppModel
    @StateObject private var groupStateObserver = GroupStateObserver()
    @SceneStorage("debugView") private var isDebugViewPresented: Bool = false
    var body: some View {
        List {
            Section {
                VStack(spacing: 20) {
                    Text("If you launch this application during FaceTime, you can start an activity. When you start an activity, the callers automatically join an activity.")
                        .onTapGesture(count: 3) { self.isDebugViewPresented.toggle() }
                    Button {
                        Task {
                            try? await AppGroupActivity().activate()
                        }
                    } label: {
                        Label(#"Start "Share chess" activity"#, systemImage: "play.fill")
                            .fontWeight(.semibold)
                    }
                    .disabled(!self.groupStateObserver.isEligibleForGroupSession)
                    .buttonStyle(.bordered)
                }
            } header: {
                Text("How to start")
            }
            Section {
                Text("You can also start SharePlay yourself. During a FaceTime call, a system menu UI for SharePlay appears at the bottom of the app. You can start SharePlay from the menu.")
            }
            Section {
                Text("If you want to join a SharePlay session that has already started, you can do so from the Control Center.")
            } header: {
                Text("Join SharePlay")
            }
            Section {
                Text("Once SharePlay has begun, it is not possible to change the window height. Adjust it beforehand.")
            }
            Section {
                Text("If SharePlay doesn’t work properly, your app versions might be different. Please update the app to the latest version and try SharePlay again.")
            }
        }
    }
}
