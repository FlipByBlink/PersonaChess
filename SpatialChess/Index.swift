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
        let offset: Float = 0.07
        return .init(x: Float(self.column - 4) * offset + (offset / 2),
                     y: 0,
                     z: Float(self.row - 4) * offset + (offset / 2))
    }
}
