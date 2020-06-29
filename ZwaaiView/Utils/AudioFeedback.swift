// swiftlint:disable:next line_length
// This file is from https://github.com/philips-software/cogito/blob/1c927919df4d9b323196b63ec8b62212047052a7/workspaces/cogito-ios-app/Cogito/AudioFeedback.swift,
// which is licensed under MIT license.

import AVFoundation

class AudioFeedback {
    static var `default` = AudioFeedback()

    var waved: Waved?
    var disabled = false

    func playWaved() {
        guard !disabled else { return }
        waved = Waved()
        waved?.play()
    }

    class Waved {
        private let player: AVAudioPlayer
        let queue = DispatchQueue.global(qos: .userInteractive)

        init?() {
            guard let url = Bundle.zwaaiView.url(forResource: "180048__unfa__sneeze", withExtension: "wav"),
                let newPlayer = try? AVAudioPlayer(contentsOf: url) else {
                    return nil
            }
            player = newPlayer
            player.delegate = self.audioSessionDeactivator
            self.player.prepareToPlay()
        }

        private let audioSessionDeactivator = DeactivateAudioSessionOnStop()

        func play() {
            queue.async {
                try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [])
                try? AVAudioSession.sharedInstance().setActive(true)
                self.player.play()
            }
        }
    }
}

@objc class DeactivateAudioSessionOnStop: NSObject, AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
