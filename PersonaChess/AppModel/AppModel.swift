import SwiftUI
import GroupActivities
import Combine

@MainActor
class AppModel: ObservableObject {
    @Published var sharedState = SharedState()
    let entities = Entities()
    @Published var movingPieces: [Piece] = []
    @Published var isImmersiveSpaceShown: Bool = false
    
    @Published var groupSession: GroupSession<AppGroupActivity>?
    var messenger: GroupSessionMessenger?
    var subscriptions: Set<AnyCancellable> = []
    var tasks: Set<Task<Void, Never>> = []
    @Published var spatialSharePlaying: Bool?
    @Published var myRole: CustomSpatialTemplate.Role? = nil
    
    let soundFeedback = SoundFeedback()
    @Published var showRecordingRoom: Bool = false
    
    init() {
        self.configureGroupSessions()
        self.updateEntities()
    }
}
