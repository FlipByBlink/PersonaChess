import SwiftUI

struct ToolbarView: View {
    var position: ToolbarPosition
    @EnvironmentObject var model: AppModel
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) var openWindow
    @Environment(\.physicalMetrics) var physicalMetrics
    @State private var expanded: Bool = false
    var body: some View {
        ZStack(alignment: .top) {
            Button {
                self.expanded = true
            } label: {
                Image(systemName: "ellipsis")
            }
            .opacity(self.expanded ? 0 : 1)
            .foregroundStyle(.secondary)
            HStack(spacing: 24) {
                Group {
                    Button {
                        self.expanded = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .symbolRenderingMode(.multicolor)
                            .frame(width: Self.circleButtonSize,
                                   height: Self.circleButtonSize)
                    }
                    HStack(spacing: 8) {
                        Button {
                            self.model.raiseBoard()
                        } label: {
                            Image(systemName: "chevron.up")
                                .frame(width: Self.circleButtonSize,
                                       height: Self.circleButtonSize)
                        }
                        Button {
                            self.model.lowerBoard()
                        } label: {
                            Image(systemName: "chevron.down")
                                .frame(width: Self.circleButtonSize,
                                       height: Self.circleButtonSize)
                        }
                    }
                    HStack(spacing: 8) {
                        Button {
                            self.model.upScale()
                        } label: {
                            Image(systemName: "plus")
                                .frame(width: Self.circleButtonSize,
                                       height: Self.circleButtonSize)
                        }
                        Button {
                            self.model.downScale()
                        } label: {
                            Image(systemName: "minus")
                                .frame(width: Self.circleButtonSize,
                                       height: Self.circleButtonSize)
                        }
                        .disabled(self.model.activityState.viewScale < 0.6)
                    }
                    Button {
                        self.model.rotateBoard()
                    } label: {
                        Image(systemName: "arrow.turn.right.up")
                            .frame(width: Self.circleButtonSize,
                                   height: Self.circleButtonSize)
                    }
                }
                .buttonBorderShape(.circle)
                Button {
                    self.model.execute(.back)
                } label: {
                    Label("Back", systemImage: "arrow.uturn.backward")
                        .padding(8)
                }
                .disabled(self.model.activityState.chess.log.isEmpty)
                Button {
                    self.model.execute(.reset)
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .padding(8)
                }
                .disabled(self.model.activityState.chess.isPreset)
                Button {
                    switch self.model.activityState.preferredScene {
                        case .fullSpace:
                            self.model.exitFullSpaceWithEveryone()
                        case .window:
                            Task {
                                self.openWindow(id: "window")
                                await self.dismissImmersiveSpace()
                            }
                    }
                } label: {
                    Label("Exit", systemImage: "escape")
                        .padding(8)
                }
            }
            .buttonStyle(.plain)
            .disabled(!self.model.movingPieces.isEmpty)
            .font(.subheadline)
            .padding(12)
            .padding(.horizontal, 16)
            .glassBackgroundEffect()
            .opacity(self.expanded ? 1 : 0)
        }
        .animation(.default, value: self.expanded)
        .rotation3DEffect(.degrees(20), axis: .x)
        .offset(z: (self.physicalMetrics.convert(FixedValue.boardSize, from: .meters) / 2) + 60)
        .rotation3DEffect(
            .degrees({
                switch self.position {
                    case .foreground: 0
                    case .front: 180
                    case .right: 90
                    case .left: 270
                }
            }()),
            axis: .y
        )
    }
}

private extension ToolbarView {
    private static let circleButtonSize = 32.0
}
