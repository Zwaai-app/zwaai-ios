import XCTest

extension XCUIApplication {
    func dismissStateWasResetWarning() {
        if self.alerts.count > 0 && self.alerts.staticTexts["Fatal error"].exists {
            self.alerts.buttons["Dismiss"].tap()
        }
    }

    func resetState() {
        self.buttons["Instellingen"].tap()
        self.buttons["Reset app state"].tap()
        self.alerts.firstMatch.buttons["Reset"].tap()
    }
}
