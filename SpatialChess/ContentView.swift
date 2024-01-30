import SwiftUI
import RealityKit

struct ContentView: View {
    @State private var rootEntity: Entity = .init()
    @State private var selected: Index?
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        RealityView { content, attachments in
            self.rootEntity.position.y = 1.2
            self.rootEntity.position.z = -1
            GameState.preset.forEach { (key: Index, value: Piece) in
                let entity = try! Entity.load(named: value.assetName)
                entity.position = key.position
                entity.components.set([
                    HoverEffectComponent(),
                    InputTargetComponent(),
                    CollisionComponent(
                        shapes: [.generateBox(size: entity.visualBounds(relativeTo: nil).extents)]
                    ),
                    PieceStateComponent(index: key)
                ])
                self.rootEntity.addChild(entity)
            }
            self.rootEntity.addChild(attachments.entity(for: "board")!)
            content.add(self.rootEntity)
        } attachments: {
            Attachment(id: "board") {
                ZStack {
                    HStack(spacing: 0) {
                        ForEach(1...8, id: \.self) {
                            Spacer()
                            if $0 < 8 { Color.primary.frame(width: 1) }
                        }
                    }
                    VStack(spacing: 0) {
                        ForEach(1...8, id: \.self) {
                            Spacer()
                            if $0 < 8 { Color.primary.frame(height: 1) }
                        }
                    }
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(lineWidth: 3)
                }
                .frame(width: self.physicalMetrics.convert(FixedValue.boardSize, from: .meters),
                       height: self.physicalMetrics.convert(FixedValue.boardSize, from: .meters))
                .padding(32)
                .glassBackgroundEffect()
                .rotation3DEffect(.degrees(90), axis: .x)
            }
        }
        .gesture(
            TapGesture()
                .targetedToEntity(where: .has(PieceStateComponent.self))
                .onEnded { value in
                    let state = value.entity.components[PieceStateComponent.self]!
                    value.entity.move(to: .init(translation: .init(x: 0,
                                                                   y: state.selected ? -0.1 : 0.1,
                                                                   z: 0)),
                                      relativeTo: value.entity,
                                      duration: 1)
                    value.entity.components[PieceStateComponent.self]!.selected.toggle()
                }
        )
    }
}
