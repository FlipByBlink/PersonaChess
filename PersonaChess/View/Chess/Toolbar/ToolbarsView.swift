import SwiftUI
import RealityKit

struct ToolbarsView: View {
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        RealityView { content, attachments in
            ToolbarPosition.allCases.forEach { position in
                let entity = attachments.entity(for: position)!
                entity.setPosition(position.position3D, relativeTo: entity)
                content.add(entity)
            }
        } attachments: {
            ForEach(ToolbarPosition.allCases) { position in
                Attachment(id: position) {
                    ToolbarView(position: position)
                }
            }
        }
        .frame(width: Size.Point.board(self.physicalMetrics), height: 60)
        .frame(depth: Size.Point.board(self.physicalMetrics))
    }
}
