import AVFAudio
import RealityKit

class SoundFeedback {
    private let putSound: [AudioFileResource] = (1...6).map { try! .load(named: "putSound\($0).m4a") }
    private let resetSound: AudioFileResource = try! .load(named: "resetSound.m4a")
    private let selectSound: AudioFileResource = try! .load(named: "selectSound.m4a")
    init() {
        try? AVAudioSession().setCategory(.ambient)
    }
}

extension SoundFeedback {
    func put(_ entity: Entity) {
        let player = entity.prepareAudio(self.putSound.randomElement()!)
        player.gain = -8
        player.play()
    }
    func reset(_ entity: Entity) {
        let player = entity.prepareAudio(self.resetSound)
        player.gain = -8
        player.play()
    }
    func select(_ entity: Entity) {
        let player = entity.prepareAudio(self.selectSound)
        player.gain = -21
        player.play()
    }
}
