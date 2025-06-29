import SwiftUI
import GroupActivities

struct HeaderMenu: View {
    @EnvironmentObject var model: AppModel
    @StateObject private var groupStateObserver = GroupStateObserver()
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Self.row(
                    "eligibleForGroupSession",
                    self.groupStateObserver.isEligibleForGroupSession.description
                )
                Self.row(
                    "groupSession.state",
                    {
                        switch self.model.groupSession?.state {
                            case .waiting: "waiting"
                            case .joined: "joined"
                            case .invalidated(reason: let error): "invalidated(\(error))"
                            case .none: "nil"
                            @unknown default: "@unknown default"
                        }
                    }()
                )
                Self.row("activeParticipants",
                         self.model.groupSession?.activeParticipants.count.description)
                Self.row("messageIndex",
                         self.model.sharedState.messageIndex?.description)
                Self.row("logs.count",
                         self.model.sharedState.logs.count.formatted())
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
    
    private static func row(_ title: String, _ value: String?) -> some View {
        HStack(alignment: .lastTextBaseline, spacing: 6) {
            Text(title + ":").bold()
            Text(value ?? "nil")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}
