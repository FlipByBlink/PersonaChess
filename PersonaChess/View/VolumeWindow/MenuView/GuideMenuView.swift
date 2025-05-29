import SwiftUI
import GroupActivities

//MARK: Work in progress
struct GuideMenuView: View {
    @EnvironmentObject var model: AppModel
    @StateObject private var groupStateObserver = GroupStateObserver()
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("What's SharePlay?") { WhatsSharePlayMenu() }
                    NavigationLink("What's Persona?") { WhatsPersonaMenu() }
                }
                if self.model.groupSession == nil {
                    Section { NavigationLink("Set up SharePlay") { self.setUpMenu() } }
                }
                Section { AboutAppLink() }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        self.model.isMenuSheetShown = false
                    } label: {
                        Label("Dismiss", systemImage: "xmark")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    OpenAndDismiss3DSpaceButton()
                }
            }
            .navigationTitle("Menu")
        }
        .padding(.bottom, 300)
    }
}

private extension GuideMenuView {
    private var isPresented: Bool {
        self.model.groupSession == nil
    }
    var isEligibleForGroupSession: Bool {
#if targetEnvironment(simulator)
        true
        //false
#else
        self.groupStateObserver.isEligibleForGroupSession
#endif
    }
    private func setUpMenu() -> some View {
        List {
            Section {
                Text("If you launch this application during FaceTime, you can start an activity. When you start an activity, the callers automatically join an activity.")
                Button {
                    self.model.activateGroupActivity()
                } label: {
                    Label(#"Start "Share chess" activity"#, systemImage: "play.fill")
                        .fontWeight(.semibold)
                }
                .disabled(!self.groupStateObserver.isEligibleForGroupSession)
            } header: {
                Text("How to start")
            }
            Section {
                Text("You can also start SharePlay yourself. During a FaceTime call, a system menu UI for SharePlay appears at the bottom of the app. You can start SharePlay from the menu.")
            }
            Section {
                Text("If you want to join a SharePlay session that has already started, you can do so from the Control Center.")
            } header: {
                Text("Join SharePlay")
            }
        }
    }
}
