import XCTest
import Nimble

class ZwaaiPersonUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testZwaaiPersonAddsHistoryEntry() throws {
        let app = XCUIApplication()
        app.launch()

        if app.alerts.count > 0 && app.alerts.staticTexts["Fatal error"].exists {
            app.alerts.buttons["Dismiss"].tap()
        }

        // Reset state
        app.buttons["Instellingen"].tap()
        app.buttons["Reset app state"].tap()
        app.alerts.firstMatch.buttons["Reset"].tap()

        // Check history
        app.buttons["Geschiedenis"].tap()
        expect(app.tables.firstMatch.staticTexts["Gezwaaid met niemand"].exists).to(beTrue())
        expect(app.tables.firstMatch.staticTexts["Nergens gezwaaid"].exists).to(beTrue())
        expect(app.tables.firstMatch.cells.staticTexts.count) == 0

        // Zwaai
        app.buttons["Zwaai"].tap()
        app.buttons["Zwaai met persoon"].tap()
        expect(app.images["QR code die de ander moet scannen"].exists).to(beTrue())
        expect(app.staticTexts.element(boundBy: 0).label) == "Persoon" // nav title
        expect(app.staticTexts.element(boundBy: 1).label).to(contain("Richt de telefoons"))
        expect(app.otherElements["Camera voorvertoning voor scannen"].exists).to(beTrue())
        app.buttons["Fake successful scan"].tap()
        _ = app.alerts.firstMatch.waitForExistence(timeout: 1)
        expect(app.alerts.firstMatch.staticTexts["Gelukt"].exists).to(beTrue())
        app.alerts.firstMatch.buttons["Volgende"].tap()

        // Check history
        app.buttons["Geschiedenis"].tap()
        expect(app.tables.firstMatch.staticTexts["Gezwaaid met 1 persoon"].exists).to(beTrue())
        expect(app.tables.firstMatch.cells.staticTexts.count) == 1
    }
}
