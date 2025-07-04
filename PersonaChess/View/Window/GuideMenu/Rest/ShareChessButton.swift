import SwiftUI
import GroupActivities

struct ShareChessButton: View {
    @StateObject private var groupStateObserver = GroupStateObserver()
    var body: some View {
        Button {
            Task {
                try? await AppGroupActivity().activate()
            }
        } label: {
            Label("Share chess", systemImage: "shareplay")
                .fontWeight(
                    self.groupStateObserver.isEligibleForGroupSession ? .semibold : .regular
                )
                .strikethrough(!self.groupStateObserver.isEligibleForGroupSession)
        }
        .disabled(!self.groupStateObserver.isEligibleForGroupSession)
        .buttonStyle(.borderedProminent)
        .tint(.green)
        .labelStyle(.titleAndIcon)
    }
}
