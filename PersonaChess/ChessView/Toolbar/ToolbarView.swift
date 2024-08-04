import SwiftUI

struct ToolbarView: View {
    var position: ToolbarPosition
    @EnvironmentObject var model: AppModel
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        ZStack(alignment: .top) {
            Button {
                self.model.expandToolbar(self.position)
            } label: {
                Image(systemName: "ellipsis")
                    .padding(24)
            }
            .buttonStyle(.plain)
            .glassBackgroundEffect()
            .opacity(self.isExpanded ? 0 : 1)
            HStack(spacing: 24) {
                Group {
                    Button {
                        self.model.closeToolbar(self.position)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .symbolRenderingMode(.multicolor)
                            .frame(width: Self.circleButtonSize,
                                   height: Self.circleButtonSize)
                    }
                    Button {
                        self.model.rotateBoard()
                    } label: {
                        Image(systemName: "arrow.turn.right.up")
                            .frame(width: Self.circleButtonSize,
                                   height: Self.circleButtonSize)
                    }
                    HStack(spacing: 16) {
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
                        Button {
                            self.model.lowerToFloor()
                        } label: {
                            Image(systemName: "arrow.down.to.line")
                                .frame(width: Self.circleButtonSize,
                                       height: Self.circleButtonSize)
                        }
                    }
                    Divider()
                        .frame(height: Self.circleButtonSize)
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
                Divider()
                    .frame(height: Self.circleButtonSize)
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
                    Divider()
                        .frame(height: Self.circleButtonSize)
                }
                Button {
                    Task { await self.dismissImmersiveSpace() }
                } label: {
                    Label("""
                          Close
                          app
                          """,
                          systemImage: "power.dotted")
                    .minimumScaleFactor(0.5)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .frame(height: Self.circleButtonSize)
                }
            }
            .buttonStyle(.plain)
            .disabled(!self.model.movingPieces.isEmpty)
            .font(.subheadline)
            .padding(12)
            .padding(.horizontal, 16)
            .glassBackgroundEffect()
            .opacity(self.isExpanded ? 1 : 0)
        }
        .animation(.default, value: self.isExpanded)
        //.rotation3DEffect(.degrees(20), axis: .x) <- temp
        .rotation3DEffect(.degrees(self.position.rotationDegrees), axis: .y)
    }
}

private extension ToolbarView {
    private var isExpanded: Bool {
        self.model.activityState.expandedToolbar.contains(self.position)
    }
    private static let circleButtonSize = 40.0
}
