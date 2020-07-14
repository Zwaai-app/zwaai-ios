import Foundation
import AVFoundation
@testable import ZwaaiLogic

class AudioSessionSpy: AudioSessionProto {
    var setCategories = [(AVAudioSession.Category, AVAudioSession.Mode, AVAudioSession.CategoryOptions)]()
    var setActives = [(Bool, AVAudioSession.SetActiveOptions)]()

    func setCategory(_ category: AVAudioSession.Category,
                     mode: AVAudioSession.Mode,
                     options: AVAudioSession.CategoryOptions) throws {
        setCategories.append((category, mode, options))
    }

    func setActive(_ active: Bool, options: AVAudioSession.SetActiveOptions) throws {
        setActives.append((active, options))
    }
}
