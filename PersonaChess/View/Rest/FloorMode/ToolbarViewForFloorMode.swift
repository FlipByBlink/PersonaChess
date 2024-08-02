import SwiftUI

struct ToolbarViewForFloorMode: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        if self.model.floorMode {
            HStack {
                Group {
                    Button {
                        self.model.separateFromFloor()
                    } label: {
                        Image(systemName: "arrow.up.to.line")
                            .frame(width: Self.circleButtonSize,
                                   height: Self.circleButtonSize)
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
            .fixedSize()
            .padding()
            .padding(.horizontal)
            .glassBackgroundEffect()
            .rotation3DEffect(.degrees(270), axis: .y)
            .offset(z: -Size.Point.board(physicalMetrics) / 2)
            .offset(x: Size.Point.board(physicalMetrics),
                    y: -Size.Point.board(physicalMetrics) / 2)
        }
    }
}

private extension ToolbarViewForFloorMode {
    private static let circleButtonSize = 48.0
}
