import GroupActivities

//Work in progress
#if os(visionOS)
struct CustomSpatialTemplate: SpatialTemplate {
    enum Role: String, SpatialTemplateRole {
        case white,
             black
    }
    
    var elements: [any SpatialTemplateElement] {
        let direction: SpatialTemplateElementDirection = {
            .lookingAt(.app.offsetBy(x: 0,
                                     z: Size.Meter.spatialZOffset))
        }()
        
        return [
            .seat(position: .app.offsetBy(x: -1, z: Size.Meter.spatialZOffset),
                  direction: direction,
                  role: Role.white),
            .seat(position: .app.offsetBy(x: 1, z: Size.Meter.spatialZOffset),
                  direction: direction,
                  role: Role.black),
            
            // Starting positions:
            .seat(position: .app.offsetBy(x: 0, z: 3), direction: direction),
            .seat(position: .app.offsetBy(x: 1, z: 3), direction: direction),
            .seat(position: .app.offsetBy(x: -1, z: 3), direction: direction),
            .seat(position: .app.offsetBy(x: 2, z: 3), direction: direction),
            .seat(position: .app.offsetBy(x: -2, z: 3), direction: direction),
        ]
    }
}
#else
struct CustomSpatialTemplate {
    enum Role: String {
        case white,
             black
    }
}
#endif
