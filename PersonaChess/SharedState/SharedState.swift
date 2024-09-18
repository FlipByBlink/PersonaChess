// SharedState.swift

import GroupActivities

struct SharedState: Codable, Equatable {
    var chess: Chess = .empty
    var viewHeight: Double = Size.Point.defaultHeight
    var viewScale: Double = 1.0
    var mode: AppMode = .localOnly  // Added AppMode from the first version
    
    // AppMode enum from the first version
    enum AppMode: String, Codable {
        case localOnly
        case sharePlay
    }
    
    // Clear function that resets the state
    mutating func clear() {
        self.chess = .empty
        self.viewHeight = Size.Point.defaultHeight
        self.viewScale = 1.0
        self.mode = .localOnly  // Reset mode when clearing
    }
}
