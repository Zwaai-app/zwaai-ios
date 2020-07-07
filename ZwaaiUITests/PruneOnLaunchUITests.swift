import XCTest
import Nimble

class PruneOnLaunchAndActivateUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testPruneOnActivate() throws {
        let app = XCUIApplication()
        app.launch()
        app.dismissStateWasResetWarning()

        app.resetState()
        app.terminate()
        app.launch()

        app.buttons["Instellingen"].tap()
        app.buttons["Prune log"].tap()
        expect(app.staticTexts["didBecomeActive/0"].exists).to(beTrue())

        app.resetState()

        app.buttons["Instellingen"].tap()
        app.buttons["Prune log"].tap()
        expect(app.buttons["Prune"].exists).to(beTrue())
        expect(app.staticTexts["didBecomeActive/0"].exists).to(beFalse())

        XCUIDevice.shared.press(.home)
        expect(app.wait(for: .runningBackground, timeout: 3)).to(beTrue())
        app.activate()
        expect(app.wait(for: .runningForeground, timeout: 3)).to(beTrue())
        expect(app.buttons["Prune"].waitForExistence(timeout: 3)).to(beTrue())
        expect(app.staticTexts["didBecomeActive/0"].exists).to(beTrue())
    }
}
