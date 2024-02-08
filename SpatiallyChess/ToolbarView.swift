import SwiftUI

struct ToolbarView: View {
    var body: some View {
        ZStack {
            ForEach(Self.Position.allCases, id: \.self) {
                Self.ContentView(position: $0)
            }
        }
    }
}

private extension ToolbarView {
    private enum Position: CaseIterable {
        case foreground, front, right, left
    }
    private struct ContentView: View {
        var position: ToolbarView.Position
        @EnvironmentObject var model: 🥽AppModel
        @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
        @Environment(\.physicalMetrics) var physicalMetrics
        @State private var expanded: Bool = true
        //@State private var expanded: Bool = false MARK: 戻す
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
                            .disabled(self.model.scale < 0.6)
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
                        self.model.executeAction(.back)
                    } label: {
                        Label("Back", systemImage: "arrow.uturn.backward")
                            .padding(8)
                    }
                    .disabled(self.model.gameState.log.isEmpty)
                    Button {
                        self.model.executeAction(.reset)
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                            .padding(8)
                    }
                    .disabled(self.model.gameState.latestSituation == FixedValue.preset)
                    Button {
                        Task { await self.dismissImmersiveSpace() }
                    } label: {
                        Label("Exit", systemImage: "escape")
                            .padding(8)
                    }
                }
                .buttonStyle(.plain)
                .font(.subheadline)
                .padding(12)
                .padding(.horizontal, 16)
                .glassBackgroundEffect()
                .opacity(self.expanded ? 1 : 0)
            }
            .animation(.default, value: self.expanded)
            .rotation3DEffect(.degrees(20), axis: .x)
            .offset(z: (self.physicalMetrics.convert(FixedValue.boardSize, from: .meters) / 2) + 80)
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
        private static let circleButtonSize = 32.0
    }
}
