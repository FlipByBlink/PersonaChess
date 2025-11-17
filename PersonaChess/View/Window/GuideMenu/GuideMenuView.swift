import SwiftUI

struct GuideMenuView: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("What's SharePlay?") { WhatsSharePlayMenu() }
                    NavigationLink("What's Persona?") { WhatsPersonaMenu() }
                }
                Section { NavigationLink("Set up SharePlay") { SetUpMenu() } }
                Section {
                    Text("Once SharePlay has begun, it is not possible to change the window height. Adjust it beforehand.")
                        .padding(.vertical, 2)
                }
                AboutOptionsMenuLink()
                Section {
                    AboutAppLink()
                } footer: {
                    self.ver1Announce()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .close) {
                        self.model.isGuideMenuShown = false
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
    @ViewBuilder
    private func ver1Announce() -> some View {
        if let date2512 = DateComponents(calendar: .current, year: 2025, month: 12).date,
           date2512 > Date.now {
            Text("""
            This app is ver 3. It is not compatible with previous versions (ver 1.0 and ver 2.0), so SharePlay does not work between them.
            If your SharePlay partners are using previous version, please recommend them to update the app.
            """)
        }
    }
}
