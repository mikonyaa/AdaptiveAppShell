import UIKit
import XCTest

@MainActor
final class StudioNavigationUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testUpcomingProjectOpensItsVisibleDetail() {
        let app = launchStudio()
        let upcoming = app.buttons["upcoming-project-spring-catalogue"]
        if !upcoming.isHittable { app.swipeUp() }
        XCTAssertTrue(upcoming.waitForExistence(timeout: 5))
        upcoming.tap()
        XCTAssertTrue(app.navigationBars["Spring catalogue"].waitForExistence(timeout: 5))
    }

    func testProjectsAndSearchOpenCorrectDetailsWithInspectorInitiallyClosed() {
        let app = launchStudio()
        let inspector = app.buttons["adaptive-shell-inspector-toggle"]
        if inspector.exists {
            closeStudioInspector(in: app)
            XCTAssertEqual(inspector.label, "Show inspector")
            XCTAssertFalse(app.staticTexts["inspector-progress"].isHittable)
        }
        selectStudioTab("Projects", in: app)
        app.buttons["project-packaging-review"].tap()
        XCTAssertTrue(app.navigationBars["Packaging review"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["inspector-progress"].isHittable)
        selectStudioTab("Search", in: app)
        app.buttons["project-website-qa"].tap()
        XCTAssertTrue(app.navigationBars["Website QA"].waitForExistence(timeout: 5))
        selectStudioTab("Projects", in: app)
        XCTAssertTrue(app.navigationBars["Packaging review"].exists)
    }

    func testProjectOpeningWithInspectorInitiallyOpen() {
        defer { XCUIDevice.shared.orientation = .portrait }
        let app = launchStudio(["--inspector"], inspectorColumn: true)
        if UIDevice.current.userInterfaceIdiom == .pad {
            XCTAssertTrue(app.staticTexts["inspector-progress"].isHittable)
        }
        app.buttons["project-spring-catalogue"].tap()
        XCTAssertTrue(app.navigationBars["Spring catalogue"].waitForExistence(timeout: 5))
        selectStudioTab("Search", in: app)
        app.buttons["project-website-qa"].tap()
        XCTAssertTrue(app.navigationBars["Website QA"].waitForExistence(timeout: 5))
        if UIDevice.current.userInterfaceIdiom == .pad {
            verifyPortraitInspectorLifecycle()
        }
    }

    private func verifyPortraitInspectorLifecycle() {
        XCUIDevice.shared.orientation = .portrait
        let app = launchStudio(["--inspector"])
        let frame = app.windows.firstMatch.frame
        XCTAssertLessThan(frame.width, frame.height)
        let initialInspector = app.scrollViews["project-inspector-spring-catalogue"]
        XCTAssertTrue(initialInspector.waitForExistence(timeout: 5))
        XCTAssertTrue(initialInspector.isHittable)
        closeStudioInspector(in: app)
        let project = app.buttons["project-website-qa"]
        XCTAssertTrue(project.isHittable)
        project.tap()
        let updatedInspector = app.scrollViews["project-inspector-website-qa"]
        XCTAssertTrue(updatedInspector.waitForExistence(timeout: 5))
        XCTAssertTrue(updatedInspector.isHittable)
        XCTAssertTrue(app.staticTexts["Sam Campbell"].isHittable)
        XCTAssertFalse(app.staticTexts["Noah Williams"].isHittable)
        closeStudioInspector(in: app)
        XCTAssertTrue(app.navigationBars["Website QA"].waitForExistence(timeout: 5))
    }

    func testColdKnownDeepLinkOpensOneCorrectDestination() {
        let known = URL(string: "adaptiveshell://project/website-qa")!
        let app = openStudioURL(known)
        XCTAssertTrue(app.navigationBars["Website QA"].waitForExistence(timeout: 15))
        if app.buttons["inspector-close"].isHittable { closeStudioInspector(in: app) }
        let back = app.navigationBars["Website QA"].buttons.matching(
            NSPredicate(format: "identifier == %@ OR label == %@", "BackButton", "Projects")
        ).firstMatch
        XCTAssertTrue(back.waitForExistence(timeout: 5))
        XCTAssertTrue(back.isHittable)
        back.tap()
        XCTAssertTrue(app.navigationBars["Projects"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["project-website-qa"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.navigationBars["Website QA"].exists)
    }

    func testColdUnknownAndMalformedDeepLinksDoNotOpenAnotherProject() {
        let app = openStudioURL(URL(string: "adaptiveshell://project/does-not-exist")!)
        XCTAssertTrue(app.alerts["Project not found"].waitForExistence(timeout: 15))
        app.alerts.buttons["OK"].tap()
        XCTAssertTrue(app.navigationBars["Overview"].waitForExistence(timeout: 5))
        _ = openStudioURL(URL(string: "adaptiveshell://project/spring-catalogue/extra")!)
        XCTAssertTrue(app.alerts["Invalid link"].waitForExistence(timeout: 15))
        app.alerts.buttons["OK"].tap()
        XCTAssertTrue(app.navigationBars["Overview"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.navigationBars["Spring catalogue"].exists)
    }

    func testAccessibilityTextKeepsProjectAndCreationControlsReachable() {
        let app = launchStudio(["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"])
        let project = app.buttons["project-spring-catalogue"]
        XCTAssertTrue(project.waitForExistence(timeout: 5))
        XCTAssertTrue(project.label.contains("Spring catalogue"))
        project.tap()
        XCTAssertTrue(app.buttons["task-spring-catalogue-cover"].waitForExistence(timeout: 5))
        app.navigationBars["Spring catalogue"].buttons.firstMatch.tap()
        app.buttons["new-project"].tap()
        XCTAssertTrue(app.textFields["new-project-name"].isHittable)
        XCTAssertTrue(app.buttons["Cancel"].isHittable)
        app.buttons["Cancel"].tap()
    }
}
