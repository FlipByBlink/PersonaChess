import SwiftUI
import GroupActivities
import Combine

@MainActor
class AppModel: ObservableObject {
    @Published var sharedState = SharedState()
    let entities = Entities()
    @Published var movingPieces: [Piece.ID] = []
    @Published var isFullSpaceShown: Bool = false
    
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


//======== Reference ========
//Drawing content in a group session | Apple Developer Documentation
//https://developer.apple.com/documentation/groupactivities/drawing_content_in_a_group_session
//
//Design spatial SharePlay experiences - WWDC23 - Videos - Apple Developer
//https://developer.apple.com/videos/play/wwdc2023/10075
//
//Build spatial SharePlay experiences - WWDC23 - Videos - Apple Developer
//https://developer.apple.com/videos/play/wwdc2023/10087
//
//Customizing spatial Persona templates | Apple Developer Documentation
//https://developer.apple.com/documentation/groupactivities/customizing-spatial-persona-templates
