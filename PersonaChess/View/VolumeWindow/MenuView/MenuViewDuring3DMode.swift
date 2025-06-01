import SwiftUI

struct MenuViewDuring3DMode: View {
    @EnvironmentObject var model: AppModel
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
            self.rolePicker()
            Spacer()
            Divider()
            Spacer()
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
        }
        .padding(.bottom)
    }
}

private extension MenuViewDuring3DMode {
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
            .padding(.horizontal, 44)
        }
    }
}
