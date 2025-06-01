import SwiftUI
import GroupActivities
import Combine

@MainActor
class AppModel: ObservableObject {
    @Published var sharedState = SharedState()
    let entities = Entities()
    @Published var isDragging: Bool = false
    @Published var isGuideMenuShown: Bool = false
    @Published var isImmersiveSpaceShown: Bool = false
    @Published var isAnimating: Bool = false
    
    @Published var groupSession: GroupSession<AppGroupActivity>?
    var messenger: GroupSessionMessenger?
    var subscriptions: Set<AnyCancellable> = []
    var tasks: Set<Task<Void, Never>> = []
    @Published var spatialSharePlaying: Bool?
    
    init() {
        self.configureGroupSessions()
        self.entities.update(self.sharedState.pieces)
    }
}
