import SwiftUI
import RealityKit

struct ChessView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        RealityView { content, attachments in
            attachments.entity(for: "board")!.name = "board"
            self.model.rootEntity.addChild(attachments.entity(for: "board")!)
            content.add(self.model.rootEntity)
        } attachments: {
            Attachment(id: "board") {
                BoardView()
                    .environmentObject(self.model)
            }
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { self.model.execute(.tapPiece($0.entity)) }
        )
        .gesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged {
                    if let pieceEntity = $0.entity.parent {
                        $0.entity.position.y = Float(self.physicalMetrics.convert(-$0.translation3D.y, to: .meters))
                        pieceEntity.position = $0.convert(Point3D(x: $0.location3D.x, y: 0, z: $0.location3D.z),
                                                          from: .local,
                                                          to: self.model.rootEntity)
                    }
                    
                    print("🖨️ ==== time ==== ", $0.time)
                    print("🖨️location3D", $0.location3D)
                    print("🖨️translation3D", $0.translation3D)
                }
                .onEnded { value in
                    //let pieceIndex: Index = .init(4, 4)
                    let pieceIndex: Index = targetIndex(x: Float(self.physicalMetrics.convert(value.location3D.x, to: .meters)),
                                                        z: Float(self.physicalMetrics.convert(value.location3D.z, to: .meters)))
                    value.entity.move(to: .identity,
                                      relativeTo: value.entity.parent!,
                                      duration: 1)
                    value.entity.parent?.move(to: .init(translation: pieceIndex.position),
                                              relativeTo: self.model.rootEntity,
                                              duration: 1)
                }
        )
        .rotation3DEffect(.degrees(self.model.activityState.boardAngle), axis: .y)
        .animation(.default, value: self.model.activityState.boardAngle)
        .frame(width: Size.Point.board(self.physicalMetrics), height: 0)
        .frame(depth: Size.Point.board(self.physicalMetrics))
        .overlay {
            if self.model.showProgressView {
                ProgressView()
                    .offset(y: -200)
                    .scaleEffect(3)
            }
        }
    }
}

func targetIndex(x: Float, z: Float) -> Index {
    let row: Int = Int(z / Size.Meter.square) - 1
    let column: Int = Int(x / Size.Meter.square) - 1
    return .init(row, column)
}
