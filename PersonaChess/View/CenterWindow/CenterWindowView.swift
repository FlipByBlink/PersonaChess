import SwiftUI

struct CenterWindowView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    var body: some View {
        ZStack {
            Color.clear
            if self.model.isImmersiveSpaceShown {
                ChessMenuView()
                    .navigationTitle("PersonaChess")
            } else {
                if self.model.isMenuSheetShown {
                    GuideMenuView()
                } else {
                    ChessView_2DMode()
                }
            }
        }
        .glassBackgroundEffect(in: .rect(cornerRadius: 20, style: .continuous))
        .frame(width: Size.Point.boardSize_2DMode,
               height: Size.Point.boardSize_2DMode)
        .ornament(attachmentAnchor: .scene(.bottom), contentAlignment: .top) {
            HStack(spacing: 24) {
                OpenButton()
                if !self.model.isImmersiveSpaceShown {
                    self.openMenuButton()
                        .disabled(self.model.isMenuSheetShown)
                }
            }
            .padding()
        }
        .animation(.default, value: self.model.isImmersiveSpaceShown)
        .animation(.default, value: self.model.isMenuSheetShown)
        .animation(.default, value: self.model.groupSession == nil)
        .task { SharePlayProvider.registerGroupActivity() }
        .onChange(of: self.scenePhase) { _, newValue in
            if newValue == .background {
                if self.model.isImmersiveSpaceShown {
                    Task { await self.dismissImmersiveSpace() }
                }
            }
        }
    }
}

private extension CenterWindowView {
    private func openMenuButton() -> some View {
        Menu {
            Group {
                Button {
                    self.model.execute(.undo)
                } label: {
                    Label("Undo", systemImage: "arrow.uturn.backward")
                }
                .disabled(self.model.sharedState.logs.isEmpty)
                Button {
                    self.model.execute(.reset)
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
                .disabled(self.model.sharedState.pieces.isPreset)
            }
            .disabled(!self.model.movingPieces.isEmpty)
        } label: {
            Text("Menu")
                .padding(12)
                .padding(.horizontal, 2)
                .frame(minHeight: 42)
        } primaryAction: {
            self.model.isMenuSheetShown = true
        }
        .glassBackgroundEffect()
    }
}
