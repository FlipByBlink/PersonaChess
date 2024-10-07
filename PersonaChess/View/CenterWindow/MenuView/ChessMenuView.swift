import SwiftUI
import GroupActivities

struct ChessMenuView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    var body: some View {
        VStack {
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
            Self.RowView(title: "Height") {
                HStack(spacing: 16) {
                    Button {
                        self.model.raiseBoard()
                    } label: {
                        Image(systemName: "chevron.up")
                    }
                    .disabled(self.model.sharedState.viewHeight > 1600)
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
            Self.RowView(title: "Floor mode") {
                Self.FloorModeToggle()
            }
            Spacer()
            Divider()
            Spacer()
            self.rolePicker()
            Spacer()
            Divider()
            Spacer()
            Self.RowView(title: "More") {
                Menu {
                    self.menuButtons()
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
#if DEBUG
            .ornament(attachmentAnchor: .scene(.top)) { HStack { self.menuButtons() } }
#endif
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
            Toggle("Floor mode", isOn: self.$value)
                .labelsHidden()
                .onAppear { self.value = self.model.floorMode }
                .onChange(of: self.value) { _, newValue in
                    if newValue {
                        self.model.lowerToFloor()
                    } else {
                        self.model.separateFromFloor()
                    }
                }
                .onChange(of: self.model.sharedState.viewHeight == 0) { _, newValue in
                    self.value = newValue
                }
        }
    }
    private func rolePicker() -> some View {
        Self.RowView(title: "Role") {
            if self.model.myRole != nil {
                Button {
                    self.model.set(role: nil)
                } label: {
                    Label("Audience", systemImage: "xmark")
                        .labelStyle(.iconOnly)
                }
                .scaleEffect(0.8, anchor: .trailing)
                .buttonBorderShape(.circle)
            }
            Button("White") { self.model.set(role: .white) }
                .disabled(self.model.myRole == .white)
            Button("Black") { self.model.set(role: .black) }
                .disabled(self.model.myRole == .black)
        }
    }
    private func menuButtons() -> some View {
        Group {
            Section {
                Button {
                    self.model.execute(.undo)
                } label: {
                    Label("Undo", systemImage: "arrow.uturn.backward")
                }
                .disabled(self.model.sharedState.logs.isEmpty)
                Button {
                    self.model.execute(.reset)
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
                .disabled(self.model.sharedState.pieces.isPreset)
            }
            .disabled(!self.model.movingPieces.isEmpty)
            Section {
                Button {
                    Task { await self.dismissImmersiveSpace() }
                } label: {
                    Label("Close chess", systemImage: "escape")
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
