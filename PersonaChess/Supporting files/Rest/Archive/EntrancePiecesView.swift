import SwiftUI
import RealityKit

//struct EntrancePiecesView: View {
//    var body: some View {
//        TimelineView(.animation) { context in
//            HStack(alignment: .bottom) {
//                ForEach([
//                    .pawn0,
//                    .pawn1,
//                    .pawn2,
//                    .pawn3,
//                    .rook0,
//                    .knight0,
//                    .bishop0,
//                    .king,
//                    .queen,
//                    .knight1,
//                    .bishop1,
//                    .rook1,
//                    .pawn4,
//                    .pawn5,
//                    .pawn6,
//                    .pawn7,
//                ] as [Chessmen], id: \.self) {
//                    Model3D(named: "\($0.role)W")
//                }
//            }
//            .rotation3DEffect(.degrees(context.date.timeIntervalSinceReferenceDate * 14),
//                              axis: .y)
//        }
//        .frame(width: EntranceWindow.size, height: Self.height)
//        .frame(depth: EntranceWindow.size)
//    }
//    static let height: CGFloat = 200
//}
