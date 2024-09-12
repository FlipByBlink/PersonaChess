//MARK: compatibility, ver1.0 - ver1.0

//MARK: Work in progress
private struct ActivityState: Codable, Equatable {
    var chess: Chess = .empty
    var boardAngle: Double = 0
    var viewHeight: Double = 1250
    var viewScale: Double = 1
    var expandedToolbar: [ToolbarPosition] = []
    var mode: Mode = .localOnly
}

enum ToolbarPosition: Codable {
    case foreground,
         front,
         right,
         left
}
