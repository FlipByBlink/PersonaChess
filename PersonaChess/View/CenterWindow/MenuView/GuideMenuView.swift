import SwiftUI
import GroupActivities

//MARK: Work in progress
struct GuideMenuView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @StateObject private var groupStateObserver = GroupStateObserver()
    var body: some View {
        List {
            Section {
                NavigationLink("What's SharePlay?") { ProgressView() }
                NavigationLink("What's Persona?") { ProgressView() }
            }
            if self.model.groupSession == nil {
                Section {
                    NavigationLink("Set up SharePlay") {
                        if self.groupStateObserver.isEligibleForGroupSession {
                            Button {
                                self.model.activateGroupActivity()
                            } label: {
                                Label(#"Start "Share chess" activity"#,
                                      systemImage: "play.fill")
                                .fontWeight(.semibold)
                            }
                        } else {
                            ProgressView()
                        }
                    }
                }
            }
            Section {
                NavigationLink {
                    List { ℹ️AboutAppContent() }
                } label: {
                    Label("About App", systemImage: "info")
                }
            }
        }
    }
}
