import Foundation

enum FixedValue {
    static let squareSize: Float = 0.07
    static var boardSize: CGFloat { .init(Self.squareSize * 8) }
    static let pickedOffset: Float = 0.1
}
