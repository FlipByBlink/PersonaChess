import SwiftUI
import AVFAudio

class 📢SoundEffect {
    private var actionPlayers: [AVAudioPlayer] = []
    private var secondEffectPlayer: AVAudioPlayer?
    init() {
        Task(priority: .background) {
            self.actionPlayers = (1...6).compactMap {
                if let ⓓata = NSDataAsset(name: "sound\($0)")?.data,
                   let ⓟlayer = try? AVAudioPlayer(data: ⓓata) {
                    ⓟlayer.volume = 0.2
                    ⓟlayer.prepareToPlay()
                    return ⓟlayer
                } else {
                    assertionFailure()
                    return nil
                }
            }
            if let ⓓata = NSDataAsset(name: "resetSound")?.data,
               let ⓟlayer = try? AVAudioPlayer(data: ⓓata) {
                self.secondEffectPlayer = ⓟlayer
                self.secondEffectPlayer?.volume = 0.13
                self.secondEffectPlayer?.prepareToPlay()
            } else {
                assertionFailure()
            }
        }
    }
    func execute() {
        Task(priority: .background) {
            self.actionPlayers.randomElement()?.play()
        }
    }
    func resetAction() {
        Task(priority: .background) {
            self.secondEffectPlayer?.play()
        }
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
