import SwiftUI
import RealityKit

struct ToolbarsView: View {
    @Environment(\.physicalMetrics) var physicalMetrics
    var targetScene: TargetScene
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
                    ToolbarView(targetScene: self.targetScene,
                                position: position)
                }
            }
        }
        .frame(width: Size.Point.board(self.physicalMetrics), height: 60)
        .frame(depth: Size.Point.board(self.physicalMetrics))
    }
}

//SwiftUI pattern
//ZStack {
//    ForEach(ToolbarPosition.allCases) {
//        ToolbarView(position: $0)
//    }
//}
//.offset(z: Size.Point.board(self.physicalMetrics) / 2)
