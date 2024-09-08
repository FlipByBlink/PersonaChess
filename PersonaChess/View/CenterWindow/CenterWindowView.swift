import SwiftUI
import GroupActivities

struct CenterWindowView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @StateObject private var groupStateObserver = GroupStateObserver()
    var body: some View {
        NavigationStack {
            ZStack {
                if self.model.isFullSpaceShown {
                    ChessMenuView()
                } else {
                    GuideMenuView()
                }
            }
            .toolbar { OpenChessButton() }
        }
        .animation(.default, value: self.model.isFullSpaceShown)
        .animation(.default, value: self.isEligibleForGroupSession)
        .frame(width: 450, height: 400)
        .task { SharePlayProvider.registerGroupActivity() }
        .onDisappear {
            if self.model.isFullSpaceShown {
                Task { await self.dismissImmersiveSpace() }
            }
        }
    }
}

private extension CenterWindowView {
    var isEligibleForGroupSession: Bool {
#if targetEnvironment(simulator)
        true
        //        false
#else
        self.groupStateObserver.isEligibleForGroupSession
#endif
    }
}
