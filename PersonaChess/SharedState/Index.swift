struct Index {
    var row: Int
    var column: Int
    
    init(_ row: Int, _ column: Int) {
        self.row = row
        self.column = column
    }
}

//(row, column)
//(0,0)(0,1)(0,2)(0,3)(0,4)(0,5)(0,6)(0,7)
//(1,0)(1,1)(1,2)(1,3)(1,4)(1,5)(1,6)(1,7)
//(2,0)(2,1)(2,2)(2,3)(2,4)(2,5)(2,6)(2,7)
//(3,0)(3,1)(3,2)...
//(4,0)(4,1)(4,2)...
//(5,0)(5,1)(5,2)...
//(6,0)(6,1)(6,2)...
//(7,0)(7,1)(7,2)...

extension Index: Hashable, Codable {
    var position: SIMD3<Float> {
        .init(x: Float(self.column - 4) * Size.Meter.square + (Size.Meter.square / 2),
              y: 0,
              z: Float(self.row - 4) * Size.Meter.square + (Size.Meter.square / 2))
    }
}
