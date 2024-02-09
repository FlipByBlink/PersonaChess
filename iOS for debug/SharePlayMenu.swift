import SwiftUI
import GroupActivities

struct SharePlayMenu: View {
    @EnvironmentObject var model: AppModel
    @StateObject private var groupStateObserver = GroupStateObserver()
    var body: some View {
        VStack {
            Text("groupSession?.state: " + String(describing: self.model.groupSession?.state))
                .font(.caption)
            VStack {
                Text("eligibleForGroupSession: \(self.groupStateObserver.isEligibleForGroupSession.description)")
                    .font(.caption)
                Button("Start activity!") { self.model.activateGroupActivity() }
                    .disabled(!self.groupStateObserver.isEligibleForGroupSession)
                Button("Restart") { self.model.restartGroupActivity() }
                    .disabled(!self.groupStateObserver.isEligibleForGroupSession)
            }
            .padding()
            .opacity({
                switch self.model.groupSession?.state {
                    case .joined: 0
                    case .waiting: 0.5
                    case .invalidated(reason: _): 0.1
                    default: 1
                }
            }())
        }
    }
}
