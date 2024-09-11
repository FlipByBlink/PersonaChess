import GroupActivities

//MARK: Work in progress
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
        
        let whiteSeats: [any SpatialTemplateElement] = {
            [0, 1, 2].map {
                .seat(position: .app.offsetBy(x: -1,
                                              z: Size.Meter.spatialZOffset - $0),
                      direction: direction,
                      role: Self.Role.white)
            }
        }()
        
        let blackSeats: [any SpatialTemplateElement] = {
            [0, 1, 2].map {
                .seat(position: .app.offsetBy(x: 1,
                                              z: Size.Meter.spatialZOffset - $0),
                      direction: direction,
                      role: Self.Role.black)
            }
        }()
        
        let defaultSeats: [any SpatialTemplateElement] = {
            [
                .seat(position: .app.offsetBy(x: 0, z: 3), direction: direction),
                .seat(position: .app.offsetBy(x: 1, z: 3), direction: direction),
                .seat(position: .app.offsetBy(x: -1, z: 3), direction: direction),
                .seat(position: .app.offsetBy(x: 2, z: 3), direction: direction),
                .seat(position: .app.offsetBy(x: -2, z: 3), direction: direction),
            ]
        }()
        
        return whiteSeats + blackSeats + defaultSeats
    }
}








#elseif os(iOS)
struct CustomSpatialTemplate {
    enum Role: String {
        case white, black
    }
}
#endif
