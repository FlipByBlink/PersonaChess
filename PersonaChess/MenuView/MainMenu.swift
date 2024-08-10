import SwiftUI
import RealityKit
import GroupActivities

struct MainMenu: View {
    @EnvironmentObject var model: AppModel
    @StateObject private var groupStateObserver = GroupStateObserver()
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("What's SharePlay?") { WhatsSharePlayMenu() }
                    NavigationLink("What's Persona?") { WhatsPersonaMenu() }
                }
                if self.isEligibleForGroupSession {
                    Text("You are currently connected with a friend. Join an activity launched by your friend, or launch an activity by yourself.")
                    Text("If your friend has already started chess activity, you can join the activity from the Control Center.")
                }
                Section { NavigationLink("Set up SharePlay") { self.setUpMenu() } }
                Section { NavigationLink("About options") { AboutOptionsMenu() } }
            }
            .font(.title3)
            .navigationTitle("PersonaChess")
            .toolbar { AboutAppLink() }
        }
        .glassBackgroundEffect()
        .padding(.horizontal, 24)
        .background { Self.pieceStatues() }
        .opacity(self.isPresented ? 1.0 : 0)
        .animation(.default, value: self.isPresented)
        .animation(.default, value: self.isEligibleForGroupSession)
        .frame(width: 1000, height: 700)
        .offset(y: -1800)
        .offset(z: self.zOffset)
    }
}

private extension MainMenu {
    private var isPresented: Bool {
        self.model.groupSession == nil
    }
    private var isEligibleForGroupSession: Bool {
#if targetEnvironment(simulator)
        true
//        false
#else
        self.groupStateObserver.isEligibleForGroupSession
#endif
    }
    private var zOffset: CGFloat {
        -Size.Point.nonSpatialZOffset - Size.Point.board(self.physicalMetrics) - 150
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
                Text("If you want to join a SharePlay session that has already started, you can do so from the Control Center.")
            } header: {
                Text("Join SharePlay")
            }
        }
    }
    private static func pieceStatues() -> some View {
        HStack {
            Model3D(named: "\(Chessmen.king)B")
                .scaleEffect(6, anchor: .bottom)
            Spacer()
                .frame(width: 2200)
            Model3D(named: "\(Chessmen.queen)W")
                .scaleEffect(6, anchor: .bottom)
        }
        .offset(y: 500)
    }
}
