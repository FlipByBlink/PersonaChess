import SwiftUI
import GroupActivities

struct SharePlayMenu: View {
    @EnvironmentObject var model: AppModel
    @StateObject private var groupStateObserver = GroupStateObserver()
    var body: some View {
        NavigationStack {
            VStack {
                Text("eligibleForGroupSession: \(self.groupStateObserver.isEligibleForGroupSession.description)")
                    .font(.caption)
                Button("Join!") { self.model.activateGroupActivity() }
                    .disabled(!self.groupStateObserver.isEligibleForGroupSession)
                Button("Restart") { self.model.restartGroupActivity() }
                    .disabled(!self.groupStateObserver.isEligibleForGroupSession)
            }
            .navigationTitle("SharePlay chess")
            .padding(32)
        }
        .glassBackgroundEffect()
        .frame(width: 500, height: 400)
        .padding(.bottom, 300)
    }
}
