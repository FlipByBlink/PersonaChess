import SwiftUI
import GroupActivities

struct GuideMenuView: View {
    @EnvironmentObject var model: AppModel
    @StateObject private var groupStateObserver = GroupStateObserver()
    @SceneStorage("debugView") private var isDebugViewPresented: Bool = false
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
                Section {
                    AboutAppLink()
                } footer: {
                    self.ver1Announce()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        self.model.isGuideMenuShown = false
                    } label: {
                        Label("Dismiss", systemImage: "xmark")
                    }
                }
            }
            .navigationTitle("Menu")
        }
        .opacity(self.model.groupSession == nil ? 1 : 0)
        .opacity(self.model.isGuideMenuShown ? 1 : 0)
        .frame(width: 500,
               height: 500)
        .animation(.default, value: self.model.isGuideMenuShown)
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
                    .onTapGesture(count: 3) { self.isDebugViewPresented.toggle() }
                Button {
                    self.model.activateGroupActivityFromInAppUI()
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
            Section {
                Text("Once SharePlay has begun, it is not possible to change the window height. Adjust it beforehand.")
            }
            Section {
                Text("If SharePlay doesn’t work properly, your app versions might be different. Please update the app to the latest version and try SharePlay again.")
            }
        }
    }
    private func ver1Announce() -> some View {
        Text("""
        This app is version 2. It was recently released. It is not compatible with the previous version (version 1.0), so SharePlay does not work between them.
        If your SharePlay partners are using version 1.0, please recommend them to update the app.
        """)
    }
}
