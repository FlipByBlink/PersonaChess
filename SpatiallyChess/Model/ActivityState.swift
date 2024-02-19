struct ActivityState: Codable, Equatable {
    var chess: Chess = .empty
    var preferredScene: PreferredScene = .window
    var boardAngle: Double = 0
    var viewHeight: Double = 1250
    var viewScale: Double = 1
}

//TODO: 検討
//extension ActivityState {
//    var isEmpty: Bool {
//        self == Self()
//    }
//}
