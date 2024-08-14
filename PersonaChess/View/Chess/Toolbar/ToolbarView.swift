import SwiftUI

struct ToolbarView: View {
    var targetScene: TargetScene
    var position: ToolbarPosition
    @EnvironmentObject var model: AppModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        ZStack(alignment: .top) {
            self.expandButton()
            HStack(spacing: 24) {
                Group {
                    Button {
                        self.model.rotateBoard()
                    } label: {
                        Image(systemName: "arrow.turn.right.up")
                            .frame(width: Self.circleButtonSize,
                                   height: Self.circleButtonSize)
                    }
                    Self.divider()
                    Button {
                        self.model.execute(.undo)
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                            .frame(width: Self.circleButtonSize,
                                   height: Self.circleButtonSize)
                    }
                    .accessibilityLabel("Undo")
                    .disabled(self.model.activityState.chess.log.isEmpty)
                    Button {
                        self.model.execute(.reset)
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .frame(width: Self.circleButtonSize,
                                   height: Self.circleButtonSize)
                    }
                    .accessibilityLabel("Reset")
                    .disabled(self.model.activityState.chess.isPreset)
                }
                .buttonBorderShape(.circle)
                Self.divider()
                if self.model.groupSession?.state == .joined {
                    Button {
                        self.model.groupSession?.leave()
                    } label: {
                        Label("""
                              Leave
                              activity
                              """,
                              systemImage: "escape")
                        .minimumScaleFactor(0.5)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .frame(height: Self.circleButtonSize)
                    }
                    Button {
                        self.model.groupSession?.end()
                    } label: {
                        Label("""
                              End
                              activity
                              """,
                              systemImage: "stop.fill")
                        .minimumScaleFactor(0.5)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .frame(height: Self.circleButtonSize)
                    }
                    Self.divider()
                }
                switch self.targetScene {
                    case .volume:
                        Button {
                            Task {
                                await self.openImmersiveSpace(id: "immersiveSpace")
                                self.dismissWindow(id: "volume")
                            }
                        } label: {
                            Label("""
                                  Enter
                                  full space
                                  """,
                                  systemImage: "arrow.up.left.and.arrow.down.right")
                            .minimumScaleFactor(0.5)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .frame(height: Self.circleButtonSize)
                        }
                    case .fullSpace:
                        Button {
                            Task {
                                self.openWindow(id: "volume")
                                await self.dismissImmersiveSpace()
                            }
                        } label: {
                            Label("""
                                  Exit
                                  full space
                                  """,
                                  systemImage: "escape")
                            .minimumScaleFactor(0.5)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .frame(height: Self.circleButtonSize)
                        }
                }
            }
            .padding(12)
            .padding(.horizontal, 16)
            .glassBackgroundEffect()
            .overlay(alignment: .leading) { self.closeButton() }
            .overlay(alignment: .bottom) { self.buttonsForFullSpace() }
            .buttonStyle(.plain)
            .disabled(!self.model.movingPieces.isEmpty)
            .font(.subheadline)
            .opacity(self.isExpanded ? 1 : 0)
        }
        .animation(.default, value: self.isExpanded)
        .rotation3DEffect(.degrees(self.position.rotationDegrees), axis: .y)
    }
}

private extension ToolbarView {
    private var isExpanded: Bool {
        self.model.activityState.expandedToolbar.contains(self.position)
    }
    private func expandButton() -> some View {
        Button {
            self.model.expandToolbar(self.position)
        } label: {
            Image(systemName: "ellipsis")
                .padding(24)
        }
        .buttonStyle(.plain)
        .glassBackgroundEffect()
        .opacity(self.isExpanded ? 0 : 1)
    }
    private func closeButton() -> some View {
        Button {
            self.model.closeToolbar(self.position)
        } label: {
            Image(systemName: "xmark")
                .resizable()
                .fontWeight(.semibold)
                .padding(12)
                .frame(width: Self.circleButtonSize,
                       height: Self.circleButtonSize)
                .padding(3)
        }
        .buttonBorderShape(.circle)
        .buttonStyle(.plain)
        .foregroundStyle(.secondary)
        .glassBackgroundEffect(in: .circle)
        .alignmentGuide(.leading) { $0.width + 12 }
    }
    private func buttonsForFullSpace() -> some View {
        HStack(spacing: 24) {
            HStack(spacing: 16) {
                Button {
                    self.model.upScale()
                } label: {
                    Image(systemName: "plus")
                        .frame(width: Self.circleButtonSize,
                               height: Self.circleButtonSize)
                }
                .disabled(!self.model.upScalable)
                Button {
                    self.model.downScale()
                } label: {
                    Image(systemName: "minus")
                        .frame(width: Self.circleButtonSize,
                               height: Self.circleButtonSize)
                }
                .disabled(!self.model.downScalable)
            }
            Self.divider()
            HStack(spacing: 16) {
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
            Self.divider()
            Button {
                self.model.lowerToFloor()
            } label: {
                Image(systemName: "arrow.down.to.line")
                    .frame(width: Self.circleButtonSize,
                           height: Self.circleButtonSize)
            }
        }
        .buttonBorderShape(.circle)
        .padding(12)
        .padding(.horizontal, 16)
        .glassBackgroundEffect()
        .opacity(self.targetScene == .fullSpace ? 1 : 0)
        .alignmentGuide(.bottom) { _ in -16 }
    }
    private static func divider() -> some View {
        Divider()
            .frame(height: Self.circleButtonSize)
    }
    private static let circleButtonSize = 40.0
}
