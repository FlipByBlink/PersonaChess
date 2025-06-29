import SwiftUI

struct DebugView: ViewModifier {
    @EnvironmentObject var model: AppModel
    @SceneStorage("debugView") private var isDebugViewPresented: Bool = false
    func body(content: Content) -> some View {
        content
#if DEBUG
            .ornament(attachmentAnchor: .scene(.leading)) {
                if self.isDebugViewPresented {
                    VStack(alignment: .leading, spacing: 12) {
                        Self.row(
                            "groupSession.state",
                            {
                                switch self.model.groupSession?.state {
                                    case .waiting: "waiting"
                                    case .joined: "joined"
                                    case .invalidated(reason: let error): "invalidated(\(error))"
                                    case .none: "nil"
                                    @unknown default: "@unknown default"
                                }
                            }()
                        )
                        Self.row("activeParticipants",
                                 self.model.groupSession?.activeParticipants.count.description)
                        Self.row("isImmersiveSpaceModePreferred",
                                 self.model.isImmersiveSpaceModePreferred?.description)
                        Self.row("spatialSharePlaying",
                                 self.model.spatialSharePlaying?.description)
                        Self.row("messageIndex",
                                 self.model.sharedState.messageIndex?.description)
                        Self.row("boardAngle",
                                 self.model.sharedState.boardAngle.formatted())
                        Self.row("logs.count",
                                 self.model.sharedState.logs.count.formatted())
                    }
                    .padding()
                }
            }
#endif
    }
    
    private static func row(_ title: String, _ value: String?) -> some View {
        HStack(alignment: .lastTextBaseline, spacing: 6) {
            Text(title + ":").bold()
            Text(value ?? "nil")
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
}
