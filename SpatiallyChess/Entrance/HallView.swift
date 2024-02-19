import SwiftUI
import RealityKit

struct HallView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow
    var body: some View {
        RealityView { content in
            let mesh: MeshResource = .generateText("Enter!",
                                                   extrusionDepth: 0.01,
                                                   font: .systemFont(ofSize: 0.15,
                                                                     weight: .bold))
            let entity = ModelEntity(mesh: mesh,
                                     materials: [SimpleMaterial(color: .white,
                                                                isMetallic: false)])
            entity.position = -(mesh.bounds.extents / 2)
            entity.components.set([
                HoverEffectComponent(),
                InputTargetComponent(),
                CollisionComponent(shapes: [.generateConvex(from: mesh)])
            ])
            content.add(entity)
        }
        .onTapGesture { self.model.enterFullSpace() }
        .onChange(of: self.model.activityState.preferredScene) { _, newValue in
            if newValue == .fullSpace {
                Task {
                    await self.openImmersiveSpace(id: "immersiveSpace")
                    self.dismissWindow(id: "window")
                }
            }
        }
    }
}
