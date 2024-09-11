import SwiftUI

struct ToolbarView: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        HStack(spacing: 24) {
            Group {
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
                    .disabled(self.model.sharedState.viewScale < 0.6)
                }
            }
            .buttonBorderShape(.circle)
            Button {
                self.model.execute(.undo)
            } label: {
                Label("Undo", systemImage: "arrow.uturn.backward")
                    .padding(8)
                    .labelStyle(.iconOnly)
                
            }
            .disabled(self.model.sharedState.chess.log.isEmpty)
            Button {
                self.model.execute(.reset)
            } label: {
                Label("Reset", systemImage: "arrow.counterclockwise")
                    .padding(8)
                    .labelStyle(.iconOnly)
            }
            .disabled(self.model.sharedState.chess.isPreset)
            if self.model.groupSession?.state == .joined {
                Button {
                    self.model.groupSession?.leave()
                } label: {
                    Label("Leave", systemImage: "escape")
                        .frame(height: Self.circleButtonSize)
                        .labelStyle(.iconOnly)
                }
                Button {
                    self.model.groupSession?.end()
                } label: {
                    Label("End", systemImage: "stop.fill")
                        .frame(height: Self.circleButtonSize)
                        .labelStyle(.iconOnly)
                }
            }
        }
        .buttonStyle(.plain)
        .font(.caption)
        .padding(12)
        .disabled(!self.model.movingPieces.isEmpty)
    }
}

private extension ToolbarView {
    private static let circleButtonSize = 32.0
}
