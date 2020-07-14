import Quick
import Nimble
@testable import ZwaaiLogic
import AVFoundation

class AudioFeedbackSpec: QuickSpec {
    override func spec() {
        var audioPlayerSpy: AudioPlayerSpy?
        var audioSessionSpy: AudioSessionSpy!
        var audioFeedback: AudioFeedback!

        context("happy path") {
            beforeEach {
                audioPlayerSpy = nil
                audioSessionSpy = AudioSessionSpy()
                let deps = AudioDeps(
                    createPlayer: { url in
                        let spy = try AudioPlayerSpy(contentsOf: url)
                        audioPlayerSpy = spy
                        return spy },
                    audioSession: audioSessionSpy)
                audioFeedback = AudioFeedback(deps: deps)
            }

            it("can play a 'waved' sound") {
                audioFeedback.playWaved()
                expect(audioPlayerSpy?.playCount).toEventually(be(1))
                expect(audioPlayerSpy?.url?.absoluteString).to(contain("180048__unfa__sneeze"))
                expect(audioPlayerSpy?.prepareToPlayCount) == 1
                expect(audioSessionSpy.setCategories).to(haveCount(1))
                expect(audioSessionSpy.setCategories[0].0) == .ambient
                expect(audioSessionSpy.setCategories[0].1) == .default
                expect(audioSessionSpy.setCategories[0].2) == []
                expect(audioSessionSpy.setActives).toEventually(haveCount(2))
                expect(audioSessionSpy.setActives[0].0) == true
                expect(audioSessionSpy.setActives[0].1) == []
                expect(audioSessionSpy.setActives[1].0) == false
                expect(audioSessionSpy.setActives[1].1) == [.notifyOthersOnDeactivation]
            }

            it("can be disabled") {
                audioFeedback.disabled = true
                audioFeedback.playWaved()
                expect(audioPlayerSpy).toEventually(beNil())
            }
        }

        context("when player creation fails") {
            beforeEach {
                audioPlayerSpy = nil
                audioSessionSpy = AudioSessionSpy()
                let deps = AudioDeps(
                    createPlayer: { _ in throw TestError.testError },
                    audioSession: audioSessionSpy)
                audioFeedback = AudioFeedback(deps: deps)
            }

            it("doesn't play") {
                audioFeedback.playWaved()
                expect(audioPlayerSpy).toEventually(beNil())
            }
        }
    }
}
