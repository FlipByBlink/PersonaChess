import SwiftUI

struct MenuViewDuring3DMode: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        VStack {
            Self.RowView(title: "Angle") {
                HStack(spacing: 16) {
                    Text(self.model.sharedState.boardAngle.formatted() + "°")
                    Button {
                        self.model.rotateBoard()
                    } label: {
                        Label("Rotate", systemImage: "arrow.turn.right.up")
                    }
                }
            }
            Divider()
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
            Self.RowView(title: "More") {
                self.subButtons()
            }
        }
        .padding()
        .border(.gray)
        .padding(.horizontal)
        .frame(maxWidth: 400)
    }
}

private extension MenuViewDuring3DMode {
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
