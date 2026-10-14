import XCTest

@MainActor
final class StudioUITests: XCTestCase {
    func testOverviewProjectOpensVisibleDetail() {
        let app = XCUIApplication()
        app.launch()
        let project = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Spring catalogue")).firstMatch
        XCTAssertTrue(project.waitForExistence(timeout: 10))
        project.tap()
        XCTAssertTrue(app.navigationBars["Spring catalogue"].waitForExistence(timeout: 5))
    }

    func testCreationOpensTheEnteredProject() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["New project"].tap()
        let field = app.textFields["Name"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText("Session project")
        app.buttons["Create"].tap()
        XCTAssertTrue(app.navigationBars["Session project"].waitForExistence(timeout: 5))
    }
}
