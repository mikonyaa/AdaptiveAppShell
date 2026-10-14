import XCTest

@MainActor
final class ConsumerUITests: XCTestCase {
    private var app: XCUIApplication!

    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testRemovingSelectedSectionShowsRemainingPublicDestination() {
        XCTAssertTrue(app.staticTexts["consumer-root-alpha"].waitForExistence(timeout: 10))
        configure("Remove selected")
        XCTAssertTrue(app.staticTexts["consumer-root-beta"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["consumer-selection"].label, "Selection: beta")
    }

    func testEmptyToLoadedAndReinsertPreservesUnrelatedDetail() {
        app.buttons["Select Beta"].tap()
        app.buttons["Open Beta detail"].tap()
        XCTAssertTrue(app.staticTexts["consumer-detail-beta"].waitForExistence(timeout: 5))
        configure("Remove other")
        configure("Clear sections")
        XCTAssertTrue(app.staticTexts["No destinations"].waitForExistence(timeout: 5))
        configure("Load sections")
        XCTAssertTrue(app.staticTexts["consumer-detail-beta"].waitForExistence(timeout: 5))
        configure("Reverse order")
        configure("Duplicate Alpha")
        XCTAssertTrue(app.staticTexts["consumer-detail-beta"].exists)
    }

    func testBothHistoriesSurvivePresentationAndHiddenPlacementChanges() {
        app.buttons["Open Alpha detail"].tap()
        app.buttons["Select Beta"].tap()
        app.buttons["Open Beta detail"].tap()
        if app.buttons["Use compact"].exists { app.buttons["Use compact"].tap() }
        XCTAssertTrue(app.staticTexts["consumer-detail-beta"].waitForExistence(timeout: 5))
        app.buttons["Select Alpha"].tap()
        XCTAssertTrue(app.staticTexts["consumer-detail-alpha"].waitForExistence(timeout: 5))
        configure("Hide Alpha")
        XCTAssertTrue(app.staticTexts["consumer-detail-beta"].waitForExistence(timeout: 5))
        app.buttons["Use regular"].tap()
        app.buttons["Select Alpha"].tap()
        XCTAssertTrue(app.staticTexts["consumer-detail-alpha"].waitForExistence(timeout: 5))
    }

    private func configure(_ action: String) {
        app.buttons["Configuration"].tap()
        app.buttons[action].tap()
    }
}
