// CustomSpatialTemplate.swift

import GroupActivities

struct CustomSpatialTemplate: SpatialTemplate {
    enum Role: String, SpatialTemplateRole {
        case white
        case black
        case participant // You can keep this if needed
    }

    var elements: [any SpatialTemplateElement] {
        let direction: SpatialTemplateElementDirection = .lookingAt(.app)

        // Define seats for white and black players
        let whiteSeat: any SpatialTemplateElement = .seat(
            position: .app.offsetBy(x: -1.0, z: -2.0),
            direction: direction,
            role: Self.Role.white
        )

        let blackSeat: any SpatialTemplateElement = .seat(
            position: .app.offsetBy(x: 1.0, z: -2.0),
            direction: direction,
            role: Self.Role.black
        )

        // You can add more seats for participants if needed
        let participantSeats: [any SpatialTemplateElement] = [
            // Example participant seat
            .seat(
                position: .app.offsetBy(x: 0.0, z: -3.0),
                direction: direction,
                role: Self.Role.participant
            )
        ]

        return [whiteSeat, blackSeat] + participantSeats
    }
}
