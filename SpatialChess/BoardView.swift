import SwiftUI

struct BoardView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<8, id: \.self) { column in
                VStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { row in
                        Group {
                            if (column + row) % 2 == 0 {
                                Rectangle()
                                    .fill(.background)
                            } else {
                                Color.clear
                                    .glassBackgroundEffect(in: .rect)
                            }
                        }
                        .contentShape(.rect)
                        .hoverEffect()
                        .onTapGesture { self.tapAction(.init(row, column)) }
                    }
                }
            }
        }
        .mask(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(lineWidth: 1.5)
        }
        .frame(width: self.physicalMetrics.convert(FixedValue.boardSize, from: .meters),
               height: self.physicalMetrics.convert(FixedValue.boardSize, from: .meters))
        .padding(48)
        .glassBackgroundEffect()
        .rotation3DEffect(.degrees(90), axis: .x)
    }
    func tapAction(_ index: Index) {
        guard let entity = self.model.rootEntity.children
            .first(where: { $0.components[PieceStateComponent.self]?.picked == true }) else {
            return
        }
        entity.move(to: .init(translation: index.position),
                    relativeTo: self.model.rootEntity,
                    duration: 1)
        entity.components[PieceStateComponent.self]?.index = index
        entity.components[PieceStateComponent.self]?.picked.toggle()
    }
}
