import Foundation

@MainActor
public struct AdaptiveShellNavigation<TabID: Hashable, Route: Hashable> {
    public let currentTab: TabID

    private let state: AdaptiveShellState<TabID, Route>

    init(
        currentTab: TabID,
        state: AdaptiveShellState<TabID, Route>
    ) {
        self.currentTab = currentTab
        self.state = state
    }

    public func select(_ tab: TabID) {
        state.select(tab)
    }

    public func push(_ route: Route) {
        state.push(route, in: currentTab)
    }

    public func push(_ route: Route, in tab: TabID) {
        state.push(route, in: tab)
    }

    public func pop() {
        state.pop(in: currentTab)
    }

    public func popToRoot() {
        state.popToRoot(in: currentTab)
    }
}
