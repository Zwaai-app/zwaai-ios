import Quick
import Nimble
@testable import ZwaaiLogic

class BuildInfoSpec: QuickSpec {
    override func spec() {
        it("loads build info") {
            let buildInfo = BuildInfo()
            expect(buildInfo.commitHash.count).toEventually(equal(7))
            expect(Data(hexEncoded: "0" + buildInfo.commitHash)).toNot(beNil())
            expect(buildInfo.branch).to(equal("master")
                || equal("develop")
                || beginWith("feature/")
                || beginWith("spike/"))
        }
    }
}
