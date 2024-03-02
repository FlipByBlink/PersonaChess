import SwiftUI
import GroupActivities

struct SharePlayMenu: View {
    @EnvironmentObject var model: AppModel
    @StateObject private var groupStateObserver = GroupStateObserver()
    var body: some View {
        NavigationStack {
            List {
                //HStack(spacing: 16) {
                //    Spacer()
                //    Image(systemName: "photo")
                //        .resizable()
                //        .frame(width: 400, height: 200)
                //    Text("Join the activity in control center.")
                //    Spacer()
                //}
                //.listRowBackground(Color.clear)
                Section {
                    NavigationLink("What's SharePlay?") { Self.whatsSharePlayMenu() }
                }
                if self.model.groupSession == nil {
                    Section {
                        NavigationLink("No activity?") { self.activityMenu() }
                    }
                }
                if self.model.groupSession?.state != nil {
                    Section { self.groupSessionStateText() }
                }
            }
            .navigationTitle("SpatiallyChess")
        }
        .glassBackgroundEffect()
        .padding(.horizontal, 24)
    }
}

private extension SharePlayMenu {
    private func groupSessionStateText() -> some View {
        LabeledContent {
            Text({
                switch self.model.groupSession?.state {
                    case .waiting: "waiting"
                    case .joined: "joined"
                    case .invalidated(reason: let error): "invalidated(\(error.localizedDescription))"
                    case .none: "none"
                    @unknown default: "@unknown default"
                }
            }())
        } label: {
            Text("groupSession?.state:")
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
                //"With SharePlay in the FaceTime app, you can stream TV shows, movies, and music in sync with friends and family while on a FaceTime call together. Enjoy a real-time connection with others on the call—with synced playback and shared controls, you see and hear the same moments at the same time."
            }
            .padding()
        }
        .navigationTitle("What's SharePlay?")
    }
    private func activityMenu() -> some View {
        List {
            Section {
                LabeledContent {
                    Text("\(self.groupStateObserver.isEligibleForGroupSession.description)")
                } label: {
                    Text("Eligible for SharePlay:")
                }
            }
            Section {
                Button("Start activity!") {
                    self.model.activateGroupActivity()
                }
                .disabled(
                    !self.groupStateObserver.isEligibleForGroupSession
                    ||
                    self.model.groupSession?.state != nil
                )
            } footer: {
                Text("If you launch this application during FaceTime, you can start an activity. When you launch an activity, the caller's device will show a notification asking them to join SharePlay.")
            }
        }
    }
}
