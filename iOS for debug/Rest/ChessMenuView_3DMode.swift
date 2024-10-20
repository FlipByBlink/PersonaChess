import SwiftUI

struct MenuViewDuring3DMode: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        VStack {
            Self.RowView(title: "Scale") {
                HStack(spacing: 16) {
                    Text(self.model.sharedState.viewScale.formatted())
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
            Divider()
            Self.RowView(title: "Height") {
                HStack(spacing: 16) {
                    Text(self.model.sharedState.viewHeight.formatted())
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
            Divider()
            Self.RowView(title: "Floor mode") {
                HStack(spacing: 16) {
                    Text(self.model.floorMode.description)
                    Self.FloorModeToggle()
                }
            }
            Divider()
            Self.RowView(title: "More") {
                HStack {
                    self.subButtons()
                    Menu {
                        self.subButtons()
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
            Divider()
            Button("ExtraLargeMode") {
                self.model.changeExtraLargeMode()
            }
        }
        .padding()
        .border(.gray)
        .padding(.horizontal)
    }
}

private extension MenuViewDuring3DMode {
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
    private func subButtons() -> some View {
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
        .disabled(self.model.isAnimating)
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
            .padding(.horizontal, 0)
        }
    }
}
