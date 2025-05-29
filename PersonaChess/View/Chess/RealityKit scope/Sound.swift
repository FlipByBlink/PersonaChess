import AVFAudio
import RealityKit

enum Sound {
    static func setCategory() {
        try? AVAudioSession().setCategory(.ambient)
    }
    
    static func asAction(_ kind: Self.Piece, gain: Double = 0) -> PlayAudioAction {
        .init(audioResourceName: kind.key,
              gain: gain)
    }
    
    enum Piece {
        case put,
             select
        var key: String {
            switch self {
                case .put: "putSound\(Self.putFileIndices.randomElement()!)"
                case .select: "\(self)Sound"
            }
        }
        static let audioLibraryComponent = AudioLibraryComponent(resources: Self.allSounds)
        static let putFileIndices = 1...6
        private static var allSounds: [String: AudioResource] {
            var value: [String: AudioResource] = [String: AudioResource]()
            Self.putFileIndices.forEach {
                value["putSound\($0)"] = try! AudioFileResource.load(named: "putSound\($0).m4a")
            }
            value[Piece.select.key] = try! AudioFileResource.load(named: "\(Piece.select)Sound.m4a")
            return value
        }
    }
    
    enum Board {
        static func playReset(_ rootEntity: Entity) {
            rootEntity.playAudio(try! AudioFileResource.load(named: "resetSound.m4a"))
        }
    }
}

//extension SoundFeedback {
//    func put(_ entity: Entity, _ isFloorMode: Bool) {
//        let player = entity.prepareAudio(self.putSound.randomElement()!)
//        player.gain = isFloorMode ? 14 : -8
//        player.play()
//    }
//    func reset(_ entity: Entity) {
//        let player = entity.prepareAudio(self.resetSound)
//        player.gain = -8
//        player.play()
//    }
//    func select(_ entity: Entity, _ isFloorMode: Bool) {
//        let player = entity.prepareAudio(self.selectSound)
//        player.gain = isFloorMode ? -8 : -21
//        player.play()
//    }
//}
