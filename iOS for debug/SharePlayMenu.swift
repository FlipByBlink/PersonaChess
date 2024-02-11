import SwiftUI
import GroupActivities

struct SharePlayMenu: View {
    @EnvironmentObject var model: AppModel
    @StateObject private var groupStateObserver = GroupStateObserver()
    var body: some View {
        VStack {
            Text({
                "groupSession?.state: "
                +
                {
                    switch self.model.groupSession?.state {
                        case .waiting: "waiting"
                        case .joined: "joined"
                        case .invalidated(reason: let error): "invalidated(\(error))"
                        case .none: "none"
                        @unknown default: "@unknown default"
                    }
                }()
            }())
            .font(.caption)
            Text("eligibleForGroupSession: \(self.groupStateObserver.isEligibleForGroupSession.description)")
                .font(.caption)
            Button("Start activity!") {
                self.model.activateGroupActivity()
            }
            .disabled(
                !self.groupStateObserver.isEligibleForGroupSession
                ||
                self.model.groupSession?.state != nil
            )
            Button("Restart") {
                self.model.restartGroupActivity()
            }
            .disabled(!self.groupStateObserver.isEligibleForGroupSession)
        }
        .padding()
    }
}
