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
        static var boardInFloorMode: CGFloat {
            .init(Self.square) * 8
        }
        static let pickedOffset: Float = 0.1
        static let spatialZOffset: CGFloat = 1.5
        static func convertFromPoint_2DMode(_ pointValue: CGFloat) -> Float {
            let ratio = Self.square / Float(Size.Point.squareSize2DMode)
            return Float(pointValue) * ratio
        }
    }
    enum Point {
#if os(visionOS)
        static func boardInnerPadding(_ physicalMetrics: PhysicalMetricsConverter) -> CGFloat {
            physicalMetrics.convert(Size.Meter.boardInnerPadding, from: .meters)
        }
        static func square(_ physicalMetrics: PhysicalMetricsConverter) -> CGFloat {
            CGFloat(physicalMetrics.convert(Size.Meter.square, from: .meters))
        }
        static func board(_ physicalMetrics: PhysicalMetricsConverter) -> CGFloat {
            physicalMetrics.convert(Size.Meter.board, from: .meters)
        }
        static func boardInFloorMode(_ physicalMetrics: PhysicalMetricsConverter) -> CGFloat {
            physicalMetrics.convert(Size.Meter.boardInFloorMode, from: .meters)
        }
        static let nonSpatialZOffset: CGFloat = 1400
        static let squareSize2DMode: CGFloat = 60.0
#endif
        static func convertFromMeter_2DMode(_ meterValue: Float) -> CGFloat {
            let ratio = Float(Self.squareSize2DMode) / Size.Meter.square
            return CGFloat(meterValue * ratio)
        }
        static let defaultHeight = 1000.0
    }
}




#if os(iOS)
extension Size.Point {
    static let squareSize2DMode: CGFloat = 40.0
}
#endif
