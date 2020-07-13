import XCTest

extension XCUIApplication {
    func dismissStateWasResetWarning() {
        if self.alerts.count > 0 && self.alerts.staticTexts["Fatal error"].exists {
            self.alerts.buttons["Dismiss"].tap()
        }
    }

    func resetState() {
        self.buttons["Instellingen"].tap()
        self.swipeUp()
        _ = self.buttons["Reset app state"].waitForExistence(timeout: 1)
        self.buttons["Reset app state"].tap()
        self.alerts.firstMatch.buttons["Reset"].tap()
    }
}
