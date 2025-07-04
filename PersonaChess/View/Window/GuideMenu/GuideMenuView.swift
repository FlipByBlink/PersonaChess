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
                AboutOptionsMenuLink()
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
                ToolbarItem(placement: .topBarTrailing) {
                    ShareChessButton()
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
        if let date2509 = DateComponents(calendar: .current, year: 2025, month: 09).date,
           date2509 > Date.now {
            Text("""
            This app is ver 2. It is not compatible with the previous version (ver 1.0), so SharePlay does not work between them.
            If your SharePlay partners are using ver 1.0, please recommend them to update the app.
            """)
        }
    }
}
