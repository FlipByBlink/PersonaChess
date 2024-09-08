import SwiftUI
import GroupActivities

struct ChessMenuView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    var body: some View {
        VStack {
            Spacer()
            Self.RowView(title: "Height") {
                HStack(spacing: 16) {
                    Button {
                        self.model.raiseBoard()
                    } label: {
                        Image(systemName: "chevron.up")
                    }
                    Button {
                        self.model.lowerBoard()
                    } label: {
                        Image(systemName: "chevron.down")
                    }
                }
            }
            Spacer()
            Divider()
            Spacer()
            Self.RowView(title: "Scale") {
                HStack(spacing: 16) {
                    Button {
                        self.model.upScale()
                    } label: {
                        Image(systemName: "plus")
                    }
                    Button {
                        self.model.downScale()
                    } label: {
                        Image(systemName: "minus")
                    }
                    .disabled(self.model.activityState.viewScale < 0.6)
                }
            }
            Spacer()
            Divider()
            Spacer()
            Self.RowView(title: "More") {
                Menu {
                    Button {
                        self.model.lowerToFloor()
                    } label: {
                        Label("Floor mode",
                              systemImage: "arrow.down.to.line")
                    }
                    Section {
                        Button {
                            self.model.execute(.back)
                        } label: {
                            Label("Back", systemImage: "arrow.uturn.backward")
                        }
                        .disabled(self.model.activityState.chess.log.isEmpty)
                        Button {
                            self.model.execute(.reset)
                        } label: {
                            Label("Reset", systemImage: "arrow.counterclockwise")
                        }
                        .disabled(self.model.activityState.chess.isPreset)
                    }
                    .disabled(!self.model.movingPieces.isEmpty)
                    Section {
                        Button {
                            Task { await self.dismissImmersiveSpace() }
                        } label: {
                            Label("Close chess", systemImage: "escape")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
            Spacer()
        }
        .padding(.bottom)
        .navigationTitle("PersonaChess")
    }
}

private extension ChessMenuView {
    private struct RowView<Content: View>: View {
        let title: LocalizedStringKey
        @ViewBuilder var content: () -> Content
        var body: some View {
            LabeledContent {
                self.content()
            } label: {
                Text(self.title)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 40)
        }
    }
}
