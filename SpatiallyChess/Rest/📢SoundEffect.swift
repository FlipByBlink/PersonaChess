import SwiftUI
import AVFAudio

class 📢SoundEffect {
    private var putSoundPlayers: [AVAudioPlayer] = []
    private var resetSoundPlayer: AVAudioPlayer?
    private var selectionSoundPlayer: AVAudioPlayer?
    init() {
        Task(priority: .background) {
            self.putSoundPlayers = (1...6).compactMap {
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
                self.resetSoundPlayer = ⓟlayer
                self.resetSoundPlayer?.volume = 0.13
                self.resetSoundPlayer?.prepareToPlay()
            } else {
                assertionFailure()
            }
            if let ⓓata = NSDataAsset(name: "selectionSound")?.data,
               let ⓟlayer = try? AVAudioPlayer(data: ⓓata) {
                self.selectionSoundPlayer = ⓟlayer
                self.selectionSoundPlayer?.volume = 0.07
                self.selectionSoundPlayer?.prepareToPlay()
            } else {
                assertionFailure()
            }
        }
    }
    func putAction() {
        Task(priority: .background) {
            self.putSoundPlayers.randomElement()?.play()
        }
    }
    func resetAction() {
        Task(priority: .background) {
            self.resetSoundPlayer?.play()
        }
    }
    func selectionAction() {
        Task(priority: .background) {
            self.selectionSoundPlayer?.play()
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
