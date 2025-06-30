/* MARK: Not adopted in current app.
import SwiftUI

struct GroupActivityRegistration: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottomTrailing) {
                ShareLink(item: AppGroupActivity(),
                          preview: SharePreview("Share chess"))
                .hidden()
            }
    }
}
*/




/* ==== Ref: Sample code app "GuessTogether" ====

```
ShareLink(item: activity, preview: SharePreview(text)).hidden()
```

```
struct GuessTogetherActivity: GroupActivity, Transferable, Sendable {
    var metadata: GroupActivityMetadata = {
        var metadata = GroupActivityMetadata()
        metadata.title = "Guess Together"
        return metadata
    }()
}
```

Document: "Building a guessing game for visionOS | Apple Developer Documentation"
https://developer.apple.com/documentation/groupactivities/building-a-guessing-game-for-visionos


This implementation feels like a strange workaround, but it seems to be the some reliable, hmm…
*/
