enum ToolbarPosition {
    case foreground,
         front,
         right,
         left
}

extension ToolbarPosition: Codable, CaseIterable, Identifiable {
    var id: Self { self }
    var position3D: SIMD3<Float> {
        switch self {
            case .foreground: [0, 0, .init(Size.Meter.board / 2)]
            case .front: [0, 0, .init(-Size.Meter.board / 2)]
            case .right: [.init(Size.Meter.board / 2), 0, 0]
            case .left: [.init(-Size.Meter.board / 2), 0, 0]
        }
    }
    var rotationDegrees: Double {
        switch self {
            case .foreground: 0
            case .front: 180
            case .right: 90
            case .left: 270
        }
    }
}
