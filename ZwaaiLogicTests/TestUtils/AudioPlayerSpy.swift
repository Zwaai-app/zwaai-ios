import Foundation
import AVFoundation
@testable import ZwaaiLogic

class AudioPlayerSpy: AudioPlayerProto {
    var url: URL?
    weak var delegate: AVAudioPlayerDelegate?
    var prepareToPlayCount = 0
    var playCount = 0

    required init(contentsOf url: URL) throws {
        self.url = url
    }

    func prepareToPlay() -> Bool {
        prepareToPlayCount += 1
        return true
    }

    func play() -> Bool {
        playCount += 1
        let unsafeCastedSelf = unsafeBitCast(self, to: AVAudioPlayer.self)
        DispatchQueue.main.async {
            self.delegate?.audioPlayerDidFinishPlaying?(unsafeCastedSelf, successfully: true)
        }
        return true
    }
}
