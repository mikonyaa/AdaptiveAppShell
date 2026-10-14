import XCTest
@testable import AdaptiveShellDemo

final class StudioRegressionTests: XCTestCase {
    func testUnknownFixtureNeverResolvesToAnotherProject() {
        let project = StudioFixtures.project(id: "does-not-exist")
        XCTAssertNil(project)
    }
}
