//MARK: compatibility, ver1.0 - ver1.0

//Archive

private struct ActivityState: Codable, Equatable {
//    var chess: Pieces = .empty
    var chess: Pieces = .preset
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

enum Mode: Codable {
    case localOnly,
         sharePlay
}
