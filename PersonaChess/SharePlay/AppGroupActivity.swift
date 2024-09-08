import GroupActivities
import SwiftUI

struct AppGroupActivity: GroupActivity {
    var metadata: GroupActivityMetadata {
        var value = GroupActivityMetadata()
        value.title = String(localized: "Share chess")
        value.type = .generic
        value.previewImage = UIImage(resource: .wholeIcon).cgImage
        return value
    }
}
