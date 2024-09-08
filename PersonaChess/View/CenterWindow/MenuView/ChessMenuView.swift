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
                    .disabled(self.model.activityState.viewHeight > 1600)
                    Button {
                        self.model.lowerBoard()
                    } label: {
                        Image(systemName: "chevron.down")
                    }
                }
                .buttonBorderShape(.circle)
                .disabled(self.model.floorMode)
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
            Spacer()
            Divider()
            Spacer()
            Self.RowView(title: "Floor mode") {
                Self.FloorModeToggle()
            }
            Spacer()
            Divider()
            Spacer()
            Self.RowView(title: "More") {
                Menu {
                    Section {
                        Button {
                            self.model.execute(.undo)
                        } label: {
                            Label("Undo", systemImage: "arrow.uturn.backward")
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
    }
}

private extension ChessMenuView {
    private struct FloorModeToggle: View {
        @EnvironmentObject var model: AppModel
        @State private var value: Bool = false
        var body: some View {
            Toggle(isOn: self.$value) { EmptyView() }
                .labelsHidden()
                .onAppear { self.value = self.model.floorMode }
                .onChange(of: self.value) { _, newValue in
                    if newValue {
                        self.model.lowerToFloor()
                    } else {
                        self.model.separateFromFloor()
                    }
                }
        }
    }
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
            .padding(.horizontal, 44)
        }
    }
}
