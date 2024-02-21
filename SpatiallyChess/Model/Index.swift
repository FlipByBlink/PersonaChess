struct Index {
    var row: Int
    var column: Int
    init(_ row: Int, _ column: Int) {
        self.row = row
        self.column = column
    }
}

extension Index: Hashable, Codable {
    var position: SIMD3<Float> {
        .init(x: Float(self.column - 4) * Size.Meter.square + (Size.Meter.square / 2),
              y: 0,
              z: Float(self.row - 4) * Size.Meter.square + (Size.Meter.square / 2))
    }
}
