import XCTest
@testable import AdaptiveAppShell

final class AdaptiveShellItemTests: XCTestCase {
    func testItemUsesFallbackSelectedSymbol() {
        let item = AdaptiveShellItem(
            id: "overview",
            title: "Overview",
            systemImage: "house"
        )

        XCTAssertEqual(item.selectedSystemImage, "house")
        XCTAssertEqual(item.compactPlacement, .tab)
    }

    func testSectionPreservesItemOrder() {
        let first = AdaptiveShellItem(id: 1, title: "First", systemImage: "1.circle")
        let second = AdaptiveShellItem(id: 2, title: "Second", systemImage: "2.circle")
        let section = AdaptiveShellSection(id: "main", items: [first, second])

        XCTAssertEqual(section.items.map(\.id), [1, 2])
    }
}

@MainActor
final class AdaptiveShellStateTests: XCTestCase {
    private enum Tab: Hashable {
        case overview
        case projects
    }

    private enum Route: Hashable {
        case project(Int)
    }

    func testPathsRemainIndependentPerTab() {
        let state = AdaptiveShellState<Tab, Route>(selection: .overview)

        state.push(.project(1))
        state.select(.projects)
        state.push(.project(2))

        XCTAssertEqual(state.paths[.overview], [.project(1)])
        XCTAssertEqual(state.paths[.projects], [.project(2)])
    }

    func testPopAndPopToRootAffectOnlyRequestedTab() {
        let state = AdaptiveShellState<Tab, Route>(
            selection: .overview,
            paths: [
                .overview: [.project(1), .project(2)],
                .projects: [.project(3)]
            ]
        )

        XCTAssertEqual(state.pop(), .project(2))
        state.popToRoot(in: .projects)

        XCTAssertEqual(state.paths[.overview], [.project(1)])
        XCTAssertEqual(state.paths[.projects], [])
    }

    func testThemePresetIdentityIsStable() {
        XCTAssertEqual(AdaptiveShellTheme.preset(.classic).id, .classic)
        XCTAssertEqual(AdaptiveShellTheme.preset(.graphite).id, .graphite)
        XCTAssertEqual(AdaptiveShellTheme.preset(.stone).id, .stone)
    }

    func testDeepLinkCanSelectTabAndReplaceOnlyItsPath() {
        let state = AdaptiveShellState<Tab, Route>(
            selection: .overview,
            paths: [.overview: [.project(1)]]
        )

        state.replacePath([.project(42)], in: .projects)
        state.select(.projects)

        XCTAssertEqual(state.selection, .projects)
        XCTAssertEqual(state.paths[.projects], [.project(42)])
        XCTAssertEqual(state.paths[.overview], [.project(1)])
    }

    func testInspectorPresentationSurvivesNavigationChanges() {
        let state = AdaptiveShellState<Tab, Route>(
            selection: .projects,
            isInspectorPresented: true
        )

        state.push(.project(7))
        state.select(.overview)

        XCTAssertTrue(state.isInspectorPresented)
        XCTAssertEqual(state.paths[.projects], [.project(7)])
    }

    func testSelectionResolverNormalizesCompactAndRegularTransitions() {
        let items = [
            AdaptiveShellItem(id: Tab.overview, title: "Overview", systemImage: "house"),
            AdaptiveShellItem(
                id: Tab.projects,
                title: "Projects",
                systemImage: "folder",
                compactPlacement: .hidden
            )
        ]

        XCTAssertEqual(
            AdaptiveShellSelectionResolver.resolve(
                current: .projects,
                items: items,
                isCompact: true
            ),
            .overview
        )
        XCTAssertEqual(
            AdaptiveShellSelectionResolver.resolve(
                current: .projects,
                items: items,
                isCompact: false
            ),
            .projects
        )
        XCTAssertEqual(
            AdaptiveShellSelectionResolver.resolve(
                current: Tab.overview,
                items: [AdaptiveShellItem<Tab>](),
                isCompact: true
            ),
            nil
        )
    }
}
