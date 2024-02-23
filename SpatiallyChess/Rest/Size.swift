import SwiftUI

enum Size {
    enum Meter {
        static let square: Float = 0.07
        static let boardInnerPadding: CGFloat = 0.04
        static var board: CGFloat {
            .init(Self.square) * 8
            +
            (Self.boardInnerPadding * 2)
        }
        static let pickedOffset: Float = 0.1
    }
    enum Point {
        static func boardInnerPadding(_ physicalMetrics: PhysicalMetricsConverter) -> CGFloat {
            physicalMetrics.convert(Size.Meter.boardInnerPadding, from: .meters)
        }
        static func board(_ physicalMetrics: PhysicalMetricsConverter) -> CGFloat {
            physicalMetrics.convert(Size.Meter.board, from: .meters)
        }
    }
}
