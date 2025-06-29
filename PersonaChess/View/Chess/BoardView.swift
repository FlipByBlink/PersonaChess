import SwiftUI

struct BoardView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    @Environment(\.sceneKind) var sceneKind
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<8) { column in
                VStack(spacing: 0) {
                    ForEach(0..<8) { row in
                        SquareView(row, column)
                    }
                }
            }
        }
        .mask(alignment: .center) { self.maskView() }
        .overlay { self.boardOutlineView() }
        .padding(self.paddingSize)
        .frame(width: self.boardSize, height: self.boardSize)
        .glassBackgroundEffect()
        .modifier(Self.MenuDuringImmersiveSpaceMode())
        .opacity(self.sceneKind == .immersiveSpace ? 0.25 : 1)
        .rotation3DEffect(.degrees(90), axis: .x)
    }
}


private extension BoardView {
    private func maskView() -> some View {
        RoundedRectangle(cornerRadius: self.sceneKind == .window ? 24 : 0,
                         style: .continuous)
    }
    private func boardOutlineView() -> some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .stroke(Color(white: 0.75), lineWidth: 3)
            .opacity(self.sceneKind == .immersiveSpace ? 0 : 1)
    }
    private var paddingSize: CGFloat {
        if self.sceneKind == .immersiveSpace {
            0
        } else {
            Size.Point.boardInnerPadding(self.physicalMetrics)
        }
    }
    private var boardSize: CGFloat {
        switch self.sceneKind {
            case .immersiveSpace:
                Size.Point.boardInFloorMode(self.physicalMetrics)
            case .window:
                Size.Point.board(self.physicalMetrics)
        }
    }
    private struct MenuDuringImmersiveSpaceMode: ViewModifier {
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
        private struct BoardPositionButtons: ViewModifier {
            @EnvironmentObject var model: AppModel
            func body(content: Content) -> some View {
                content
                    .overlay(alignment: .top) {
                        if self.model.spatialSharePlaying == true { self.button(.up) }
                    }
                    .overlay(alignment: .leading) { self.button(.left) }
                    .overlay(alignment: .trailing) { self.button(.right) }
                    .overlay(alignment: .bottom) {
                        if self.model.spatialSharePlaying == true { self.button(.down) }
                    }
            }
            private func button(_ boardPosition: BoardPosition) -> some View {
                Button {
                    withAnimation {
                        if self.model.sharedState.boardPosition == boardPosition {
                            self.model.sharedState.boardPosition = .center
                        } else {
                            self.model.sharedState.boardPosition = boardPosition
                        }
                    }
                } label: {
                    Image(systemName: "chevron.\(boardPosition)")
                        .padding(24)
                        .font(.system(size: 32))
                        .opacity(
                            self.model.sharedState.boardPosition == boardPosition ? 1 : 0.3
                        )
                        .bold(self.model.sharedState.boardPosition == boardPosition)
                }
                .buttonBorderShape(.circle)
                .buttonStyle(.borderless)
                .padding(48)
            }
        }
    }
}
