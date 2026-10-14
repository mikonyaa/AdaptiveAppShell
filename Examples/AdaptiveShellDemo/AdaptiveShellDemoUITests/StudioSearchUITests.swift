import XCTest

@MainActor
final class StudioSearchUITests: XCTestCase {
    func testPeopleScopeShowsEmptyStateAndRetainsQueryAcrossRotationAndTabs() {
        defer { XCUIDevice.shared.orientation = .portrait }
        let app = launchStudio(["--search"])
        replaceSearchQuery("spring", in: app)
        app.buttons["People"].tap()
        XCTAssertTrue(app.staticTexts["No results"].waitForExistence(timeout: 5))
        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertEqual(app.searchFields.firstMatch.value as? String, "spring")
        XCTAssertTrue(app.staticTexts["No results"].exists)
        selectStudioTab("Overview", in: app)
        selectStudioTab("Search", in: app)
        XCTAssertEqual(app.searchFields.firstMatch.value as? String, "spring")
        XCTAssertTrue(app.staticTexts["No results"].exists)
    }

    func testTaskSearchOpensAnEditableTaskAndPeopleSearchShowsNamedPerson() {
        let app = launchStudio(["--search"])
        replaceSearchQuery("forms", in: app)
        app.buttons["Tasks"].tap()
        app.buttons["search-task-website-qa/forms"].tap()
        XCTAssertTrue(app.buttons["task-detail-toggle"].waitForExistence(timeout: 5))
        app.buttons["task-detail-toggle"].tap()
        XCTAssertEqual(app.buttons["task-detail-toggle"].value as? String, "Complete")
        app.navigationBars["Task"].buttons.firstMatch.tap()
        replaceSearchQuery("sam", in: app)
        app.buttons["People"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["search-person-SC"].waitForExistence(timeout: 5))
    }
}
