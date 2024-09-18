// AppGroupActivity.swift

import GroupActivities

struct AppGroupActivity: GroupActivity {
    static var activityIdentifier = "net.volucam.PersonaChess.AppGroupActivity"
    
    let matchedAppleID: String

    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "Persona Chess Match"
        metadata.type = .generic
        return metadata
    }
}
