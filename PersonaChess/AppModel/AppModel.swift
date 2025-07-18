import SwiftUI
import GroupActivities
import Combine

@MainActor
class AppModel: ObservableObject {
    @Published var sharedState = SharedState()
    let entities = Entities()
    @Published var isGuideMenuShown: Bool = false
    @Published var isImmersiveSpaceShown: Bool = false
    @Published var isAnimating: Bool = false
    
    @Published var groupSession: GroupSession<AppGroupActivity>?
    var reliableMessenger: GroupSessionMessenger?
    var unreliableMessenger: GroupSessionMessenger?
    var subscriptions: Set<AnyCancellable> = []
    var tasks: Set<Task<Void, Never>> = []
    @Published var isImmersiveSpaceModePreferred: Bool?
    @Published var spatialSharePlaying: Bool?
    
    init() {
        self.configureGroupSessions()
        self.entities.update(.preset)
    }
}
