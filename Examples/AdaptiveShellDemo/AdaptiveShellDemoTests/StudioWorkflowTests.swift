import AdaptiveAppShell
import XCTest
@testable import AdaptiveShellDemo

@MainActor
final class StudioWorkflowTests: XCTestCase {
    func testScopedSearchUsesVisibleResultsForItsEmptyCondition() {
        let store = StudioStore()
        store.searchQuery = " spring "
        store.searchScope = .people
        XCTAssertTrue(store.searchResults.isEmpty)
        XCTAssertEqual(store.searchResults.people.count, 0)
        store.searchScope = .projects
        XCTAssertEqual(store.searchResults.projects.map(\.id), ["spring-catalogue"])
    }

    func testEveryEmptyQueryScopeIncludesOnlyItsOwnResults() {
        let store = StudioStore()
        store.searchQuery = " \n "
        for scope in StudioSearchScope.allCases {
            store.searchScope = scope
            let result = store.searchResults
            XCTAssertFalse(result.isEmpty, scope.rawValue)
            XCTAssertEqual(result.projects.isEmpty, scope == .tasks || scope == .people)
            XCTAssertEqual(result.tasks.isEmpty, scope == .projects || scope == .people)
            XCTAssertEqual(result.people.isEmpty, scope == .projects || scope == .tasks)
        }
    }

    func testSearchTrimsQueryAndIgnoresCase() {
        let store = StudioStore()
        store.searchQuery = " WEBSITE "
        XCTAssertEqual(store.searchResults.projects.map(\.id), ["website-qa"])
        store.searchScope = .tasks
        XCTAssertEqual(store.searchResults.tasks.map(\.task.id), ["forms", "mobile", "launch"])
        store.searchScope = .people
        store.searchQuery = " sAm "
        XCTAssertEqual(store.searchResults.people.map(\.id), ["SC"])
        for scope in StudioSearchScope.allCases {
            store.searchScope = scope
            store.searchQuery = "no-such-result"
            XCTAssertTrue(store.searchResults.isEmpty)
        }
    }

    func testCreationRejectsBlankNamesAndPreservesStableIdentity() throws {
        let store = StudioStore()
        let count = store.projects.count
        XCTAssertNil(store.createProject(name: " \n ", category: "", dueDate: .now))
        XCTAssertEqual(store.projects.count, count)
        let project = try XCTUnwrap(store.createProject(name: " Local project ", category: " Web ", dueDate: .now))
        XCTAssertEqual(project.name, "Local project")
        XCTAssertEqual(project.category, "Web")
        XCTAssertEqual(store.project(id: project.id)?.id, project.id)
        store.searchQuery = "local PROJECT"
        XCTAssertEqual(store.searchResults.projects.map(\.id), [project.id])
    }

    func testTaskCompletionUpdatesTheSharedProjectAndProgress() throws {
        let store = StudioStore()
        XCTAssertEqual(store.project(id: "spring-catalogue")?.progress, 0.4)
        XCTAssertEqual(store.upcomingTasks.first?.task.id, "images")
        store.toggleTask("images", in: "spring-catalogue")
        let project = try XCTUnwrap(store.project(id: "spring-catalogue"))
        XCTAssertEqual(project.progress, 0.6)
        XCTAssertEqual(store.upcomingTasks.first?.task.id, "proof")
        XCTAssertTrue(try XCTUnwrap(project.tasks.first { $0.id == "images" }).isComplete)
        XCTAssertEqual(store.project(id: "website-qa")?.progress, 0)
        store.toggleTask("missing", in: "spring-catalogue")
        XCTAssertEqual(store.project(id: "spring-catalogue")?.progress, 0.6)
    }

    func testProjectOpeningUsesVisiblePathsRegardlessOfInspectorOrPresentation() {
        for presentation in [AdaptiveShellPresentation.compact, .regular] {
            let store = StudioStore()
            let state = AdaptiveShellState<StudioTab, StudioRoute>(selection: .overview)
            let coordinator = StudioCoordinator(store: store, state: state)
            for source in [StudioTab.overview, .projects, .search] {
                XCTAssertTrue(coordinator.openProject("website-qa", from: source, presentation: presentation))
                XCTAssertEqual(state.selection, source)
                XCTAssertEqual(state.paths[source]?.last, .project("website-qa"))
                XCTAssertFalse(state.isInspectorPresented)
            }
            store.keepInspectorOpen = true
            coordinator.openProject("spring-catalogue", from: .projects, presentation: presentation)
            XCTAssertTrue(state.isInspectorPresented)
            XCTAssertEqual(state.paths[.overview], [.project("website-qa")])
        }
    }

    func testKnownRepeatedLinksReplaceOnlyTheirOwnPathAndUnknownLinksPreserveHistory() {
        let store = StudioStore()
        let state = AdaptiveShellState<StudioTab, StudioRoute>(
            selection: .overview, paths: [.overview: [.project("website-qa")]]
        )
        let coordinator = StudioCoordinator(store: store, state: state)
        let known = URL(string: "adaptiveshell://project/spring-catalogue")!
        coordinator.handleDeepLink(known)
        coordinator.handleDeepLink(known)
        XCTAssertEqual(state.paths[.projects], [.project("spring-catalogue")])
        XCTAssertEqual(state.paths[.overview], [.project("website-qa")])
        coordinator.handleDeepLink(URL(string: "adaptiveshell://project/does-not-exist")!)
        XCTAssertEqual(state.paths[.projects], [.project("spring-catalogue")])
        XCTAssertEqual(coordinator.selectedProjectID, "spring-catalogue")
        XCTAssertEqual(coordinator.navigationMessage?.title, "Project not found")
        coordinator.handleDeepLink(URL(string: "adaptiveshell://project/spring-catalogue/extra")!)
        XCTAssertEqual(state.paths[.projects], [.project("spring-catalogue")])
        XCTAssertEqual(coordinator.navigationMessage?.title, "Invalid link")
    }

    func testDeepLinkParserRejectsAmbiguousURLsBeforeNavigation() {
        let malformed = [
            "https://project/spring-catalogue", "adaptiveshell://project", "adaptiveshell://project/",
            "adaptiveshell://project/spring-catalogue/extra", "adaptiveshell://project//spring-catalogue",
            "adaptiveshell://project/spring%2Fcatalogue", "adaptiveshell://project/spring-catalogue?extra=1",
            "adaptiveshell://project/spring-catalogue#part", "adaptiveshell://user@project/spring-catalogue",
            "adaptiveshell://project:123/spring-catalogue", "adaptiveshell://search/extra"
        ]
        for value in malformed {
            XCTAssertEqual(StudioDeepLink.parse(URL(string: value)!), .invalid, value)
        }
        XCTAssertEqual(StudioDeepLink.parse(URL(string: "adaptiveshell://search")!), .search)
        XCTAssertEqual(StudioDeepLink.parse(URL(string: "adaptiveshell://project/website-qa")!), .project("website-qa"))
    }
}
