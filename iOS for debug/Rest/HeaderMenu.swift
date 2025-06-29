import SwiftUI
import GroupActivities

struct HeaderMenu: View {
    @EnvironmentObject var model: AppModel
    @StateObject private var groupStateObserver = GroupStateObserver()
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
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
            }
            Spacer()
            Button("Start activity!") {
                self.model.activateGroupActivity()
            }
            .disabled(
                !self.groupStateObserver.isEligibleForGroupSession
                ||
                self.model.groupSession?.state != nil
            )
            .buttonStyle(.bordered)
        }
        .padding()
    }
}
