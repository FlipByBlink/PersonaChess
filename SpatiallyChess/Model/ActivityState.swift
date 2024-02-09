struct ActivityState: Codable, Equatable {
    var chess: Chess = .init()
    var boardAngle: Double = 0
    var viewHeight: Double = 1000
    var viewScale: Double = 1
}
