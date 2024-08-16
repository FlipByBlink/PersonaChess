import SwiftUI
import RealityKit

struct ToolbarViewOnHand: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        RealityView { content, attachments in
            let entity = attachments.entity(for: "id")!
            entity.components.set(AnchoringComponent(.hand(.left,
                                                           location: .wrist)))
            content.add(entity)
        } attachments: {
            Attachment(id: "id") {
                Self.ContentView()
            }
        }
    }
}

private extension ToolbarViewOnHand {
    private struct ContentView: View {
        @EnvironmentObject var model: AppModel
        @Environment(\.openWindow) var openWindow
        @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
        @State private var isExpanded: Bool = false
        private static let circleButtonSize = 40.0
        private static let dividerSize = 150.0
        var body: some View {
            ZStack(alignment: .leading) {
                Button {
                    self.isExpanded = true
                } label: {
                    Image(systemName: "line.horizontal.3")
                        .imageScale(.small)
                        .padding(8)
                }
                .buttonStyle(.plain)
                .glassBackgroundEffect()
                .opacity(0.8)
                .opacity(self.isExpanded ? 0 : 1)
                VStack(spacing: 14) {
                    HStack(spacing: 28) {
                        HStack(spacing: 12) {
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
                            .disabled(self.model.floorMode)
                        }
                        Button {
                            if self.model.floorMode {
                                self.model.separateFromFloor()
                            } else {
                                self.model.lowerToFloor()
                            }
                        } label: {
                            Image(systemName: {
                                if self.model.floorMode {
                                    "arrow.up.to.line"
                                } else {
                                    "arrow.down.to.line"
                                }
                            }())
                            .frame(width: Self.circleButtonSize,
                                   height: Self.circleButtonSize)
                        }
                    }
                    .buttonBorderShape(.circle)
                    Divider()
                        .frame(width: Self.dividerSize)
                    HStack(spacing: 28) {
                        HStack(spacing: 12) {
                            Button {
                                self.model.upScale()
                            } label: {
                                Label("Larger", systemImage: "plus")
                                    .labelStyle(.iconOnly)
                                    .frame(width: Self.circleButtonSize,
                                           height: Self.circleButtonSize)
                            }
                            .disabled(!self.model.upScalable)
                            Button {
                                self.model.downScale()
                            } label: {
                                Label("Smaller", systemImage: "minus")
                                    .labelStyle(.iconOnly)
                                    .frame(width: Self.circleButtonSize,
                                           height: Self.circleButtonSize)
                            }
                            .disabled(!self.model.downScalable)
                        }
                        Button {
                            self.model.rotateBoard()
                        } label: {
                            Label("Rotate", systemImage: "arrow.turn.right.up")
                                .labelStyle(.iconOnly)
                                .frame(width: Self.circleButtonSize,
                                       height: Self.circleButtonSize)
                        }
                    }
                    .buttonBorderShape(.circle)
                    Divider()
                        .frame(width: Self.dividerSize)
                    HStack(spacing: 28) {
                        Button {
                            self.model.execute(.undo)
                        } label: {
                            Label("Undo", systemImage: "arrow.uturn.backward")
                                .labelStyle(.iconOnly)
                                .frame(width: Self.circleButtonSize,
                                       height: Self.circleButtonSize)
                        }
                        .disabled(self.model.activityState.chess.log.isEmpty)
                        Button {
                            self.model.execute(.reset)
                        } label: {
                            Label("Reset", systemImage: "arrow.counterclockwise")
                                .labelStyle(.iconOnly)
                                .frame(width: Self.circleButtonSize,
                                       height: Self.circleButtonSize)
                        }
                        .disabled(self.model.activityState.chess.isPreset)
                    }
                    .buttonBorderShape(.circle)
                    Divider()
                        .frame(width: Self.dividerSize)
                    Group {
                        if self.model.groupSession?.state == .joined {
                            Button {
                                self.model.groupSession?.end()
                            } label: {
                                Label("End activity", systemImage: "stop.fill")
                            }
                        } else {
                            Button {
                                Task {
                                    self.openWindow(id: "volume")
                                    await self.dismissImmersiveSpace()
                                }
                            } label: {
                                Label("Exit full space", systemImage: "escape")
                            }
                        }
                    }
                    .font(.caption)
                }
                .disabled(!self.model.movingPieces.isEmpty)
                .fixedSize()
                .padding()
                .padding(.horizontal, 8)
                .glassBackgroundEffect()
                .overlay(alignment: .top) {
                    Button {
                        self.isExpanded = false
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
                    .alignmentGuide(.top) { $0.height + 12 }
                }
                .offset(x: 50)
                .opacity(self.isExpanded ? 1 : 0)
            }
            .rotation3DEffect(.degrees(90), axis: .z)
            .rotation3DEffect(.degrees(270), axis: .x)
            .offset(z: -210)
            .animation(.default, value: self.isExpanded)
        }
    }
}
