import SwiftUI
import RealityKit

//MARK: Work in progress
struct RecordingRoom: View {
    @EnvironmentObject var model: AppModel
    @State private var startedFadeIn: Bool = false
    var body: some View {
        if self.model.showRecordingRoom {
            RealityView { content in
                if let entity = try? await Entity(named: "RoomItems") {
                    content.add(entity)
                    let clone = entity.clone(recursive: true)
                    clone.setOrientation(simd_quatf(angle: .pi, axis: [0, 1, 0]),
                                         relativeTo: nil)
                    content.add(clone)
                }
                if let entity = try? await Entity(named: "Wall") {
                    entity.scale.x *= -1
                    content.add(entity)
                }
                if let entity = try? await Entity(named: "Plane") {
                    content.add(entity)
                }
                self.startedFadeIn = true
            } placeholder: {
                ProgressView()
            }
            .opacity(self.startedFadeIn ? 1 : 0)
            .animation(.default.speed(0.3), value: self.startedFadeIn)
            .onDisappear { self.startedFadeIn = false }
        }
    }
}
