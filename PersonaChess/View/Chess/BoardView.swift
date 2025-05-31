import SwiftUI

struct BoardView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    @Environment(\.sceneKind) var sceneKind
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<8, id: \.self) { column in
                VStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { row in
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
        .modifier(Self.MenuDuringFloorMode())
        .opacity(self.sceneKind == .immersiveSpace ? 0.25 : 1)
        .modifier(Self.SharePlayStateLoading())
        .rotation3DEffect(.degrees(90), axis: .x)
    }
}


private extension BoardView {
    private func maskView() -> some View {
        RoundedRectangle(cornerRadius: self.sceneKind == .volume ? 24 : 0,
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
            case .volume:
                Size.Point.board(self.physicalMetrics)
        }
    }
    private struct SharePlayStateLoading: ViewModifier {
        @EnvironmentObject var model: AppModel
        func body(content: Content) -> some View {
            content
                .overlay {
                    if self.model.isSharePlayStateNotSet {
                        ProgressView()
                            .offset(z: 10)
                    }
                }
                .animation(.default, value: self.model.isSharePlayStateNotSet)
        }
    }
    private struct MenuDuringFloorMode: ViewModifier { //MARK: WIP
        @EnvironmentObject var model: AppModel
        @Environment(\.sceneKind) var sceneKind
        @Environment(\.physicalMetrics) var physicalMetrics
        private var isEnabled: Bool {
            self.sceneKind == .volume
            &&
            self.model.isImmersiveSpaceShown
        }
        func body(content: Content) -> some View {
            content
                .overlay {
                    if self.isEnabled {
                        VStack(spacing: 24) {
                            HStack(spacing: 16) {
                                Button {
                                    self.model.upScale()
                                } label: {
                                    Image(systemName: "plus")
                                }
                                .disabled(!self.model.upScalable)
                                Button {
                                    self.model.downScale()
                                } label: {
                                    Image(systemName: "minus")
                                }
                                .disabled(!self.model.downScalable)
                            }
                            .buttonBorderShape(.circle)
                        }
                        .font(.largeTitle)
                        .frame(width: Size.Point.board(self.physicalMetrics)/2,
                               height: Size.Point.board(self.physicalMetrics)/2)
                        .modifier(Self.BoardPositionButtons())
                        .glassBackgroundEffect(in: .circle)
                        .offset(z: 32)
                    }
                }
        }
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
                    if self.model.sharedState.boardPosition == boardPosition {
                        self.model.sharedState.boardPosition = .center
                    } else {
                        self.model.sharedState.boardPosition = boardPosition
                    }
                } label: {
                    Image(systemName: "chevron.\(boardPosition)")
                        .padding()
                        .font(.largeTitle)
                        .opacity(
                            self.model.sharedState.boardPosition == boardPosition ? 1 : 0.3
                        )
                }
                .buttonBorderShape(.circle)
                .buttonStyle(.borderless)
                .padding(24)
            }
        }
    }
}
