//MARK: Suspension

import GroupActivities

struct CustomSpatialTemplate: SpatialTemplate {
    enum Role: String, SpatialTemplateRole {
        case white,
             black
    }
    
    var elements: [any SpatialTemplateElement] {
        Self.whiteSeats
        +
        Self.blackSeats
        +
        Self.defaultSeats
    }
}

private extension CustomSpatialTemplate {
    private static var direction: SpatialTemplateElementDirection {
        .lookingAt(.app.offsetBy(x: 0,
                                 z: Size.Meter.spatialZOffset))
    }
    
    private static var whiteSeats: [some SpatialTemplateElement] {
        [0, 1, 2].map {
            .seat(position: .app.offsetBy(x: -1 - $0,
                                          z: Size.Meter.spatialZOffset),
                  direction: direction,
                  role: Self.Role.white)
        }
    }
    
    private static var blackSeats: [some SpatialTemplateElement] {
        [0, 1, 2].map {
            .seat(position: .app.offsetBy(x: 1 + $0,
                                          z: Size.Meter.spatialZOffset),
                  direction: direction,
                  role: Self.Role.black)
        }
    }
    
    private static var defaultSeats: [some SpatialTemplateElement] {
        [.seat(position: .app.offsetBy(x: 0, z: 3), direction: direction),
         .seat(position: .app.offsetBy(x: 1, z: 3), direction: direction),
         .seat(position: .app.offsetBy(x: -1, z: 3), direction: direction),
         .seat(position: .app.offsetBy(x: 2, z: 3), direction: direction),
         .seat(position: .app.offsetBy(x: -2, z: 3), direction: direction)]
    }
}
