// swiftlint:disable:next line_length
// This file is from https://github.com/philips-software/cogito/blob/1c927919df4d9b323196b63ec8b62212047052a7/workspaces/cogito-ios-app/Cogito/AudioFeedback.swift,
// which is licensed under MIT license.

import AVFoundation

class AudioFeedback {
    static var `default` = AudioFeedback()
    let deps: AudioDeps

    init(deps: AudioDeps = .default) {
        self.deps = deps
    }

    var waved: Waved?
    var disabled = false

    func playWaved() {
        guard !disabled else { return }
        waved = Waved(deps: deps)
        waved?.play()
    }

    class Waved {
        private var player: AudioPlayerProto
        let queue = DispatchQueue.global(qos: .userInteractive)
        let deps: AudioDeps

        init?(deps: AudioDeps) {
            self.deps = deps
            guard let url = Bundle.zwaaiLogic.url(forResource: "180048__unfa__sneeze", withExtension: "wav"),
                let newPlayer = try? deps.createPlayer(url) else {
                    return nil
            }
            player = newPlayer
            player.delegate = self.audioSessionDeactivator
            _ = self.player.prepareToPlay()
        }

        private lazy var audioSessionDeactivator = DeactivateAudioSessionOnStop(deps: deps)

        func play() {
            queue.async {
                try? self.deps.audioSession.setCategory(.ambient, mode: .default, options: [])
                try? self.deps.audioSession.setActive(true, options: [])
                _ = self.player.play()
            }
        }
    }
}

@objc class DeactivateAudioSessionOnStop: NSObject, AVAudioPlayerDelegate {
    let deps: AudioDeps

    init(deps: AudioDeps) {
        self.deps = deps
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        try? deps.audioSession.setActive(false, options: .notifyOthersOnDeactivation)
    }
}

struct AudioDeps {
    static var `default` = AudioDeps(
        createPlayer: { url in try AVAudioPlayer.init(contentsOf: url) },
        audioSession: AVAudioSession.sharedInstance()
    )

    let createPlayer: (_ url: URL) throws -> AudioPlayerProto
    let audioSession: AudioSessionProto
}

protocol AudioPlayerProto {
    init(contentsOf url: URL) throws
    var delegate: AVAudioPlayerDelegate? { get set }
    func prepareToPlay() -> Bool
    func play() -> Bool
}

extension AVAudioPlayer: AudioPlayerProto {}

protocol AudioSessionProto {
    func setCategory(_ category: AVAudioSession.Category,
                     mode: AVAudioSession.Mode,
                     options: AVAudioSession.CategoryOptions) throws
    func setActive(_ active: Bool, options: AVAudioSession.SetActiveOptions) throws
}

extension AVAudioSession: AudioSessionProto {}
