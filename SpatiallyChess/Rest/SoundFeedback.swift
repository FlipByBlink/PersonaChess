import SwiftUI
import AVFAudio

class SoundFeedback {
    private var putSoundPlayers: [AVAudioPlayer] = []
    private var resetSoundPlayer: AVAudioPlayer?
    private var selectSoundPlayer: AVAudioPlayer?
    init() {
        Task(priority: .background) {
            self.putSoundPlayers = (1...6).compactMap {
                if let ⓓata = NSDataAsset(name: "sound\($0)")?.data,
                   let ⓟlayer = try? AVAudioPlayer(data: ⓓata) {
                    ⓟlayer.volume = 0.18
                    ⓟlayer.prepareToPlay()
                    return ⓟlayer
                } else {
                    assertionFailure()
                    return nil
                }
            }
            if let ⓓata = NSDataAsset(name: "resetSound")?.data,
               let ⓟlayer = try? AVAudioPlayer(data: ⓓata) {
                self.resetSoundPlayer = ⓟlayer
                self.resetSoundPlayer?.volume = 0.15
                self.resetSoundPlayer?.prepareToPlay()
            } else {
                assertionFailure()
            }
            if let ⓓata = NSDataAsset(name: "selectSound")?.data,
               let ⓟlayer = try? AVAudioPlayer(data: ⓓata) {
                self.selectSoundPlayer = ⓟlayer
                self.selectSoundPlayer?.volume = 0.09
                self.selectSoundPlayer?.prepareToPlay()
            } else {
                assertionFailure()
            }
        }
    }
}

extension SoundFeedback {
    func put() {
        Task(priority: .background) {
            self.putSoundPlayers.randomElement()?.play()
        }
    }
    func reset() {
        Task(priority: .background) {
            self.resetSoundPlayer?.play()
        }
    }
    func select() {
        Task(priority: .background) {
            self.selectSoundPlayer?.play()
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
