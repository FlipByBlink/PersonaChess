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
        .onTapGesture { self.enterFullSpace() }
        .task {
            if let systemCoordinator = await self.model.groupSession?.systemCoordinator {
                for await immersionStyle in systemCoordinator.groupImmersionStyle {
                    if immersionStyle != nil {
                        self.enterFullSpace()
                    }
                }
            }
        }
    }
}

private extension HallView {
    private func enterFullSpace() {
        Task {
            await self.openImmersiveSpace(id: "immersiveSpace")
            self.dismissWindow(id: "window")
        }
    }
}
