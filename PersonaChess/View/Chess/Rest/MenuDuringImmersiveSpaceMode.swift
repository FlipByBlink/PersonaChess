import SwiftUI

struct MenuDuringImmersiveSpaceMode: ViewModifier {
    @EnvironmentObject var model: AppModel
    @Environment(\.sceneKind) var sceneKind
    @Environment(\.physicalMetrics) var physicalMetrics
    func body(content: Content) -> some View {
        content
            .overlay {
                if self.sceneKind == .window,
                   self.model.isImmersiveSpaceShown {
                    VStack(spacing: 32) {
                        HStack(spacing: 20) {
                            let size: CGFloat = 80
                            Button {
                                self.model.upScale()
                            } label: {
                                Image(systemName: "plus")
                                    .frame(width: size, height: size)
                            }
                            .disabled(!self.model.upScalable)
                            Button {
                                self.model.downScale()
                            } label: {
                                Image(systemName: "minus")
                                    .frame(width: size, height: size)
                            }
                            .disabled(!self.model.downScalable)
                        }
                        .buttonBorderShape(.circle)
                    }
                    .font(.system(size: 36))
                    .frame(width: Size.Point.board(self.physicalMetrics) * 0.7,
                           height: Size.Point.board(self.physicalMetrics) * 0.7)
                    .modifier(Self.BoardPositionButtons())
                    .glassBackgroundEffect(in: .circle)
                    .offset(z: 0.00001)
                }
            }
    }
}

private extension MenuDuringImmersiveSpaceMode {
    private struct BoardPositionButtons: ViewModifier {
        @EnvironmentObject var model: AppModel
        func body(content: Content) -> some View {
            content
                .overlay(alignment: .top) { self.button(.up) }
                .overlay(alignment: .leading) { self.button(.left) }
                .overlay(alignment: .trailing) { self.button(.right) }
                .overlay(alignment: .bottom) { self.button(.down) }
        }
        private func button(_ boardPosition: BoardPosition) -> some View {
            Button {
                self.model.changeBoardPosition(boardPosition)
            } label: {
                Image(systemName: "chevron.\(boardPosition)")
                    .padding(24)
                    .font(.system(size: 32))
                    .opacity(
                        self.model.sharedState.boardPosition == boardPosition ? 1 : 0.3
                    )
                    .bold(self.model.sharedState.boardPosition == boardPosition)
                    .overlay {
                        if self.model.sharedState.boardPosition == boardPosition {
                            Circle()
                                .strokeBorder(.tertiary, lineWidth: 3)
                        }
                    }
            }
            .buttonBorderShape(.circle)
            .buttonStyle(.borderless)
            .padding(48)
        }
    }
}
