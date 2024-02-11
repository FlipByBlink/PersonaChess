import SwiftUI
import GroupActivities

struct SharePlayMenu: View {
    @EnvironmentObject var model: AppModel
    @StateObject private var groupStateObserver = GroupStateObserver()
    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent {
                        Text("\(self.groupStateObserver.isEligibleForGroupSession.description)")
                    } label: {
                        Text("Eligible for SharePlay:")
                    }
                } footer: {
                    Text("SharePlay can be used during a FaceTime call.")
                }
                Button("Start activity!") { self.model.activateGroupActivity() }
                    .disabled(!self.groupStateObserver.isEligibleForGroupSession)
                Section {
                    self.groupSessionStateText()
                }
            }
            .navigationTitle("SpatiallyChess")
            .padding(32)
        }
        .glassBackgroundEffect()
        .opacity(self.model.groupSession?.state == .joined ? 0 : 1)
        .frame(width: 800, height: 500)
        .padding(.bottom, 300)
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
    private func restartButton() -> some View {
        Button("Restart") { self.model.restartGroupActivity() }
            .disabled(!self.groupStateObserver.isEligibleForGroupSession)
    }
}
