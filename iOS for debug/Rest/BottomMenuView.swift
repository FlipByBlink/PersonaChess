import SwiftUI

struct BottomMenuView: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        VStack {
            self.subButtons()
            VStack {
                Self.RowView(title: "Angle") {
                    HStack(spacing: 16) {
                        Text(self.model.sharedState.boardAngle.formatted() + "°")
                        Button("Rotate", systemImage: "arrow.turn.right.up") {
                            self.model.rotateBoard()
                        }
                        .labelStyle(.iconOnly)
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
            }
            .padding()
            .border(.gray)
        }
        .padding(.horizontal)
        .frame(maxWidth: 400)
    }
}

private extension BottomMenuView {
    private func subButtons() -> some View {
        HStack {
            Button("remove", systemImage: "delete.left") {
                if let pickedPiece = self.model.sharedState.pieces.pickingPiece {
                    self.model.execute(.remove(pickedPiece))
                }
            }
            .disabled(self.model.sharedState.pieces.pickingPiece == nil)
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
        .font(.caption)
        .buttonStyle(.bordered)
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
