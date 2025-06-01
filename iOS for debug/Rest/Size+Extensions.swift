import SwiftUI

extension Size.Meter {
    static func convertFromPoint_2DMode(_ pointValue: CGFloat) -> Float {
        let ratio = Self.square / Float(Size.Point.squareSize_2DMode)
        return Float(pointValue) * ratio
    }
}
extension Size.Point {
    static let squareSize_2DMode: CGFloat = 40.0
    //static var boardSize_2DMode: CGFloat { Self.squareSize_2DMode * 8 }
    static func convertFromMeter_2DMode(_ meterValue: Float) -> CGFloat {
        let ratio = Float(Self.squareSize_2DMode) / Size.Meter.square
        return CGFloat(meterValue * ratio)
    }
}
