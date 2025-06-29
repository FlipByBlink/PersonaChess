import SwiftUI
import GroupActivities

struct HeaderMenu: View {
    @EnvironmentObject var model: AppModel
    @StateObject private var groupStateObserver = GroupStateObserver()
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text("__eligibleForGroupSession:__ \(self.groupStateObserver.isEligibleForGroupSession.description)")
                Text(.init({
                    "__groupSession.state:__ "
                    +
                    {
                        switch self.model.groupSession?.state {
                            case .waiting: "waiting"
                            case .joined: "joined"
                            case .invalidated(reason: let error): "invalidated(\(error))"
                            case .none: "nil"
                            @unknown default: "@unknown default"
                        }
                    }()
                }()))
                Text("__messageIndex:__ \(self.model.sharedState.messageIndex?.formatted() ?? "nil")")
            }
            .font(.caption)
            Spacer()
            Group {
                if self.model.groupSession?.state == nil {
                    Button("Start activity!") {
                        self.model.activateGroupActivityFromInAppUI()
                    }
                    .disabled(!self.groupStateObserver.isEligibleForGroupSession)
                } else {
                    Button("Leave activity") {
                        self.model.groupSession?.leave()
                    }
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}
