import UIKit
import XCTest

@MainActor
final class StudioAdaptationUITests: XCTestCase {
    func testSearchContextResultsAndDestinationSurviveBothPresentationReplacements() throws {
        continueAfterFailure = false
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            throw XCTSkip("Regular replacement needs the independently selected wide iPad test host.")
        }
        let app = XCUIApplication()
        app.launchArguments = ["--search"]
        app.launch()
        replaceQuery("spring", in: app)
        app.buttons["People"].tap()
        XCTAssertTrue(app.staticTexts["No results"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.tabBars.buttons["Search"].exists)

        app.buttons["Use regular"].tap()
        XCTAssertEqual(app.staticTexts["adaptation-mode"].label, "Regular presentation")
        XCTAssertFalse(app.tabBars.firstMatch.exists)
        assertPeopleContext(in: app)
        app.buttons["Use compact"].tap()
        XCTAssertEqual(app.staticTexts["adaptation-mode"].label, "Compact presentation")
        XCTAssertTrue(app.tabBars.buttons["Search"].exists)
        assertPeopleContext(in: app)

        app.buttons["All"].tap()
        replaceQuery("website", in: app)
        app.buttons["project-website-qa"].tap()
        XCTAssertTrue(app.navigationBars["Website QA"].waitForExistence(timeout: 5))
        app.buttons["Use regular"].tap()
        XCTAssertFalse(app.tabBars.firstMatch.exists)
        XCTAssertTrue(app.navigationBars["Website QA"].waitForExistence(timeout: 5))
        app.buttons["Use compact"].tap()
        XCTAssertTrue(app.tabBars.firstMatch.exists)
        XCTAssertTrue(app.navigationBars["Website QA"].waitForExistence(timeout: 5))
        app.navigationBars["Website QA"].buttons.firstMatch.tap()
        XCTAssertEqual(app.searchFields.firstMatch.value as? String, "website")
        XCTAssertTrue(app.buttons["project-website-qa"].exists)
    }

    private func assertPeopleContext(in app: XCUIApplication) {
        let field = app.searchFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        XCTAssertEqual(field.value as? String, "spring")
        field.tap()
        field.typeText("\n")
        XCTAssertTrue(app.buttons["People"].isSelected)
        XCTAssertTrue(app.staticTexts["No results"].exists)
    }

    private func replaceQuery(_ query: String, in app: XCUIApplication) {
        let field = app.searchFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        let value = field.value as? String ?? ""
        field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: value.count) + query + "\n")
    }
}
