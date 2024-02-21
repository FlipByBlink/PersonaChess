import SwiftUI

enum Size {
    enum Meter {
        static let square: Float = 0.07
        static let pickedOffset: Float = 0.1
        static let boardOuterPadding: CGFloat = 0.015
        static var volume: CGFloat {
            .init(Self.square) * 8
            +
            (Self.boardOuterPadding * 2)
        }
    }
    enum Point {
        static let boardInnerPadding: CGFloat = 48
        static func board(_ physicalMetrics: PhysicalMetricsConverter) -> CGFloat {
            physicalMetrics.convert(.init(Size.Meter.square * 8), from: .meters)
            +
            (Self.boardInnerPadding * 2)
        }
        static func boardOuterPadding(_ physicalMetrics: PhysicalMetricsConverter) -> CGFloat {
            physicalMetrics.convert(Size.Meter.boardOuterPadding, from: .meters)
        }
        static func volume(_ physicalMetrics: PhysicalMetricsConverter) -> CGFloat {
            Self.board(physicalMetrics)
            +
            (Self.boardOuterPadding(physicalMetrics) * 2)
        }
    }
}
