import AVFAudio
import RealityKit

class SoundFeedback {
    private let putSound: [AudioFileResource] = (1...6).map { try! .load(named: "putSound\($0)") }
    private let resetSound: AudioFileResource = try! .load(named: "resetSound")
    private let selectSound: AudioFileResource = try! .load(named: "selectSound")
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
        player.gain = -8
        player.play()
    }
    static func setCategory() {
        do {
            try AVAudioSession().setCategory(.ambient)
        } catch {
            print(error)
            assertionFailure()
        }
    }
}
