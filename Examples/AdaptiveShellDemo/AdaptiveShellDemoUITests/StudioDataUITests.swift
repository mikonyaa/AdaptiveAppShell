import UIKit
import XCTest

@MainActor
final class StudioDataUITests: XCTestCase {
    func testBlankAndCancelledCreationDoNotCreateThenValidProjectAppearsInListAndSearch() {
        let app = launchStudio()
        app.buttons["new-project"].tap()
        XCTAssertFalse(app.buttons["Create"].isEnabled)
        app.textFields["new-project-name"].tap()
        app.textFields["new-project-name"].typeText("   ")
        XCTAssertFalse(app.buttons["Create"].isEnabled)
        app.buttons["Cancel"].tap()
        app.buttons["new-project"].tap()
        app.textFields["new-project-name"].tap()
        app.textFields["new-project-name"].typeText("Created locally")
        app.buttons["Create"].tap()
        XCTAssertTrue(app.navigationBars["Created locally"].waitForExistence(timeout: 5))
        app.navigationBars["Created locally"].buttons.firstMatch.tap()
        let created = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Created locally")).firstMatch
        XCTAssertTrue(created.waitForExistence(timeout: 5))
        selectStudioTab("Search", in: app)
        replaceSearchQuery("created locally", in: app)
        let searchResult = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Created locally")).firstMatch
        XCTAssertTrue(searchResult.waitForExistence(timeout: 5))
        searchResult.tap()
        XCTAssertTrue(app.navigationBars["Created locally"].exists)
    }

    func testTaskChangesUpdateProgressAndSettingsHaveVisibleEffects() {
        defer { XCUIDevice.shared.orientation = .portrait }
        let app = launchStudio(inspectorColumn: true)
        app.buttons["project-spring-catalogue"].tap()
        XCTAssertEqual(app.staticTexts["detail-progress"].label, "40%")
        let task = app.buttons["task-spring-catalogue-images"]
        XCTAssertEqual(task.value as? String, "Incomplete")
        task.tap()
        XCTAssertEqual(task.value as? String, "Complete")
        XCTAssertEqual(app.staticTexts["detail-progress"].label, "60%")
        selectStudioTab("Settings", in: app)
        toggleStudioSetting("show-project-progress", in: app)
        XCTAssertEqual(app.switches["show-project-progress"].value as? String, "0")
        selectStudioTab("Overview", in: app)
        XCTAssertFalse(app.staticTexts["detail-progress"].exists)
        XCTAssertEqual(app.buttons["task-spring-catalogue-images"].value as? String, "Complete")
        selectStudioTab("Settings", in: app)
        toggleStudioSetting("keep-inspector-open", in: app)
        XCTAssertEqual(app.switches["keep-inspector-open"].value as? String, "1")
        selectStudioTab("Projects", in: app)
        app.buttons["project-website-qa"].tap()
        XCTAssertTrue(app.navigationBars["Website QA"].exists)
    }

    func testInspectorReadsTheSameSelectedProjectOwnersTasksAndProgress() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            throw XCTSkip("This test requires the independently selected regular iPad destination.")
        }
        defer { XCUIDevice.shared.orientation = .portrait }
        let app = launchStudio(["--inspector"])
        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertTrue(app.buttons["adaptive-shell-inspector-toggle"].waitForExistence(timeout: 10))
        app.buttons["project-spring-catalogue"].tap()
        XCTAssertTrue(app.buttons["adaptive-shell-inspector-toggle"].waitForExistence(timeout: 5))
        let progress = app.staticTexts["inspector-progress"]
        XCTAssertTrue(progress.waitForExistence(timeout: 5))
        XCTAssertTrue(progress.isHittable)
        let frame = app.windows.firstMatch.frame
        XCTAssertGreaterThan(frame.width, frame.height)
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.lifetime = .keepAlways
        add(screenshot)
        app.buttons["task-spring-catalogue-images"].tap()
        XCTAssertEqual(app.staticTexts["inspector-progress"].label, "60%")
        selectStudioTab("Projects", in: app)
        app.buttons["project-website-qa"].tap()
        XCTAssertTrue(app.staticTexts["Sam Campbell"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Noah Williams"].exists)
        XCTAssertTrue(app.staticTexts["Test contact forms · 18 Jul"].exists)
    }
}
