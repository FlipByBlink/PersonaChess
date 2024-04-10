import SwiftUI
import GroupActivities

struct SharePlayMenu: View {
    @EnvironmentObject var model: AppModel
    @StateObject private var groupStateObserver = GroupStateObserver()
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("What's SharePlay?") { Self.whatsSharePlayMenu() }
                }
                if self.isEligibleForGroupSession {
                    Text("You are currently connected with a friend. Join an activity launched by your friend, or launch an activity by yourself.")
                    Text("If your friend has already started chess activity, you can join the activity by manipulating the system-side UI.")
                }
                if self.model.groupSession == nil {
                    Section {
                        NavigationLink("Set up SharePlay") { self.activityMenu() }
                    }
                }
                if self.model.groupSession?.state != nil {
                    Section { self.groupSessionStateText() }
                }
            }
            .font(.title3)
            .navigationTitle("PersonaChess")
            .toolbar {
                NavigationLink {
                    List { ℹ️AboutAppContent() }
                } label: {
                    Label("About App", systemImage: "info")
                        .padding(14)
                }
                .buttonBorderShape(.circle)
                .buttonStyle(.plain)
            }
        }
        .glassBackgroundEffect()
        .padding(.horizontal, 24)
        .opacity(self.showMenu ? 1 : 0)
        .animation(.default, value: self.showMenu)
        .animation(.default, value: self.isEligibleForGroupSession)
    }
}

private extension SharePlayMenu {
    var showMenu: Bool {
#if targetEnvironment(simulator)
        true
//        false
#else
        self.model.groupSession == nil
#endif
    }
    var isEligibleForGroupSession: Bool {
#if targetEnvironment(simulator)
        true
//        false
#else
        self.groupStateObserver.isEligibleForGroupSession
#endif
    }
    private func groupSessionStateText() -> some View {
        LabeledContent {
            Text({
                switch self.model.groupSession?.state {
                    case .waiting:
                        "waiting"
                    case .joined:
                        "joined"
                    case .invalidated(reason: let error):
                        "invalidated, (\(error.localizedDescription))"
                    case .none:
                        "none"
                    @unknown default:
                        "unknown"
                }
            }() as LocalizedStringKey)
        } label: {
            Text("SharePlay state:")
        }
    }
    private static func whatsSharePlayMenu() -> some View {
        List {
            HStack(spacing: 24) {
                Image(.exampleSharePlay)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 360)
                Text("With SharePlay in the FaceTime app, you can play chess in sync with friends and family while on a FaceTime call together. Enjoy a real-time connection with others on the call—with synced game and shared controls, you see and hear the same moments at the same time.")
            }
            .padding()
            Section {
                Text("The Group Activities framework uses end-to-end encryption on all session data. Developer and Apple doesn’t have the keys to decrypt this data.")
            } header: {
                Text("About data")
            }
        }
        .navigationTitle("What's SharePlay?")
    }
    private func activityMenu() -> some View {
        List {
            Section {
                Text("If you launch this application during FaceTime, you can start an activity. When you launch an activity, the caller's device will show a notification asking them to join SharePlay.")
                LabeledContent {
                    Text("\(self.groupStateObserver.isEligibleForGroupSession)")
                } label: {
                    Text("Eligible for SharePlay:")
                }
            } header: {
                Text("How to start")
            }
            Section {
                Text("You can also start SharePlay yourself. Please manipulate the system-side UI.")
                Text("Once you have started an activity, encourage your friends to join SharePlay.")
            } header: {
                Text("Start SharePlay by oneself")
            }
//            Section {
//                Button("Start activity!") {
//                    self.model.activateGroupActivity()
//                }
//                .disabled(
//                    !self.groupStateObserver.isEligibleForGroupSession
//                    ||
//                    self.model.groupSession?.state != nil
//                )
//            }
        }
    }
}
