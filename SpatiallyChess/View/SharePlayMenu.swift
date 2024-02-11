import SwiftUI
import GroupActivities

struct SharePlayMenu: View {
    @EnvironmentObject var model: AppModel
    @StateObject private var groupStateObserver = GroupStateObserver()
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("eligibleForGroupSession: \(self.groupStateObserver.isEligibleForGroupSession.description)")
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
                Button("Start activity!") { self.model.activateGroupActivity() }
                    .disabled(!self.groupStateObserver.isEligibleForGroupSession)
                Button("Restart") { self.model.restartGroupActivity() }
                    .disabled(!self.groupStateObserver.isEligibleForGroupSession)
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
