import GroupActivities

//Work in progress
struct CustomSpatialTemplate: SpatialTemplate {
    enum Role: String, SpatialTemplateRole {
        case playerL,
             playerR
    }
    
    var elements: [any SpatialTemplateElement] {
        let direction: SpatialTemplateElementDirection = {
            .lookingAt(.app.offsetBy(x: 0,
                                     z: Size.Meter.spatialZOffset))
        }()
        
        return [
            .seat(position: .app.offsetBy(x: -1, z: 2),
                  direction: direction,
                  role: Role.playerL),
            .seat(position: .app.offsetBy(x: 1, z: 2),
                  direction: direction,
                  role: Role.playerR),
            
            // Starting positions:
            .seat(position: .app.offsetBy(x: 0, z: 3), direction: direction),
            .seat(position: .app.offsetBy(x: 1, z: 3), direction: direction),
            .seat(position: .app.offsetBy(x: -1, z: 3), direction: direction),
            .seat(position: .app.offsetBy(x: 2, z: 3), direction: direction),
            .seat(position: .app.offsetBy(x: -2, z: 3), direction: direction),
        ]
    }
}
