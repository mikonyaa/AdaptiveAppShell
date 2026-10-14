import UIKit
import XCTest

@MainActor
extension XCTestCase {
    func openStudioURL(_ url: URL) -> XCUIApplication {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.terminate()
        let sender = XCUIApplication(bundleIdentifier: "dev.liquidglasstemplates.adaptiveshell.adaptation")
        sender.launchArguments = ["--open-url", url.absoluteString]
        sender.launch()
        sender.buttons["open-demo-link"].tap()
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let open = springboard.buttons.matching(
            NSPredicate(format: "label IN %@", ["Open", "Открыть"])
        ).firstMatch
        if open.waitForExistence(timeout: 3) { open.tap() }
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        return app
    }

    func launchStudio(_ arguments: [String] = [], inspectorColumn: Bool = false) -> XCUIApplication {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = arguments
        app.launch()
        XCTAssertTrue(app.buttons["new-project"].waitForExistence(timeout: 10))
        if inspectorColumn && UIDevice.current.userInterfaceIdiom == .pad {
            XCUIDevice.shared.orientation = .landscapeLeft
            let landscape = XCTNSPredicateExpectation(
                predicate: NSPredicate { object, _ in
                    guard let window = object as? XCUIElement else { return false }
                    return window.frame.width > window.frame.height
                },
                object: app.windows.firstMatch
            )
            wait(for: [landscape], timeout: 10)
            let frame = app.windows.firstMatch.frame
            XCTAssertGreaterThan(frame.width, frame.height)
        }
        if !arguments.contains("--inspector") && app.buttons["inspector-close"].isHittable {
            closeStudioInspector(in: app)
        }
        return app
    }

    func selectStudioTab(_ title: String, in app: XCUIApplication) {
        let tab = app.tabBars.buttons[title]
        if tab.exists {
            tab.tap()
        } else {
            let sidebar = app.buttons[title].firstMatch
            if !sidebar.isHittable {
                let showSidebar = app.buttons["Show Sidebar"]
                if showSidebar.exists { showSidebar.tap() }
            }
            XCTAssertTrue(sidebar.waitForExistence(timeout: 5), title)
            sidebar.tap()
        }
    }

    func closeStudioInspector(in app: XCUIApplication) {
        let toggle = app.buttons["adaptive-shell-inspector-toggle"]
        guard toggle.waitForExistence(timeout: 5) else {
            XCTFail("The regular window must expose its inspector control.")
            return
        }
        let close = app.buttons["inspector-close"]
        if toggle.label == "Hide inspector" || close.isHittable {
            XCTAssertTrue(close.waitForExistence(timeout: 5))
            XCTAssertTrue(close.isHittable)
            close.tap()
            let hidden = XCTNSPredicateExpectation(
                predicate: NSPredicate(format: "hittable == false"), object: close
            )
            wait(for: [hidden], timeout: 5)
        }
        XCTAssertEqual(toggle.label, "Show inspector")
    }

    func replaceSearchQuery(_ query: String, in app: XCUIApplication) {
        let field = app.searchFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        let value = field.value as? String ?? ""
        field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: value.count) + query)
        field.typeText("\n")
    }

    func toggleStudioSetting(_ identifier: String, in app: XCUIApplication) {
        let row = app.switches[identifier]
        let control = row.switches.firstMatch
        if control.exists { control.tap() } else { row.tap() }
    }
}
