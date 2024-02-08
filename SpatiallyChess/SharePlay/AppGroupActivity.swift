import GroupActivities
import SwiftUI

struct AppGroupActivity: GroupActivity {
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = String(localized: "Chess")
        metadata.type = .generic
//        metadata.previewImage = UIImage(resource: .whole).cgImage
        return metadata
    }
}

extension AppGroupActivity: Transferable {}
