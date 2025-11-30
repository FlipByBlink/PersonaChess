import SwiftUI

struct GuideMenuView: View {
    @EnvironmentObject var model: AppModel
    @AppStorage("PreVersAnnounceIsClosed") var preVersAnnounceIsClosed: Bool = false
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("What's SharePlay?") { WhatsSharePlayMenu() }
                    NavigationLink("What's Persona?") { WhatsPersonaMenu() }
                }
                Section { NavigationLink("Set up SharePlay") { SetUpMenu() } }
                if !self.preVersAnnounceIsClosed {
                    Self.PreVersAnnounce(self.$preVersAnnounceIsClosed)
                }
                Section {
                    Text("Once SharePlay has begun, it is not possible to change the window height. Adjust it beforehand.")
                        .padding(.vertical, 2)
                }
                AboutOptionsMenuLink()
                Section { AboutAppLink() }
            }
            .animation(.default, value: self.preVersAnnounceIsClosed)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .close) {
                        self.model.isGuideMenuShown = false
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Text("App ver \(🗒️StaticInfo.versionInfos.first!.0)")
                        .foregroundStyle(.secondary)
                        .fontWeight(.semibold)
                        .font(.subheadline)
                }
            }
            .navigationTitle("Menu")
        }
        .opacity(self.model.groupSession == nil ? 1 : 0)
        .opacity(self.model.isGuideMenuShown ? 1 : 0)
        .animation(.default, value: self.model.isGuideMenuShown)
        .frame(width: 500,
               height: 500)
        .padding(.bottom, 200)
    }
}

private extension GuideMenuView {
    private struct PreVersAnnounce: View {
        @Binding var isClosed: Bool
        var body: some View {
            if let date2601 = DateComponents(calendar: .current, year: 2026, month: 1).date,
               date2601 > Date.now {
                HStack(alignment: .top) {
                    Text("""
                    This app is ver 3. It is not compatible with previous versions (ver 1.0 and ver 2.0), so SharePlay does not work between them.
                    If your SharePlay partners are using previous version, please recommend them to update the app.
                    """)
                    .font(.subheadline)
                    Button {
                        self.isClosed = true
                    } label: {
                        Label("Close", systemImage: "xmark.circle.fill")
                            .labelStyle(.iconOnly)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.secondary)
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .listRowBackground(Color.clear)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.background)
                        .stroke(.secondary, lineWidth: 3)
                }
            }
        }
        init(_ isClosed: Binding<Bool>) {
            self._isClosed = isClosed
        }
    }
}
