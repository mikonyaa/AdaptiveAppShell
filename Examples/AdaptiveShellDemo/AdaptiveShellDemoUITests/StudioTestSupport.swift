import XCTest

@MainActor
extension XCTestCase {
    func launchStudio(_ arguments: [String] = []) -> XCUIApplication {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = arguments
        app.launch()
        XCTAssertTrue(app.buttons["new-project"].waitForExistence(timeout: 10))
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
