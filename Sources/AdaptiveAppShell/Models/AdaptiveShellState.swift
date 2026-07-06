import Observation
import SwiftUI

@MainActor
@Observable
public final class AdaptiveShellState<TabID: Hashable, Route: Hashable> {
    public var selection: TabID
    public var paths: [TabID: [Route]]
    public var columnVisibility: NavigationSplitViewVisibility
    public var isInspectorPresented: Bool

    public init(
        selection: TabID,
        paths: [TabID: [Route]] = [:],
        columnVisibility: NavigationSplitViewVisibility = .automatic,
        isInspectorPresented: Bool = false
    ) {
        self.selection = selection
        self.paths = paths
        self.columnVisibility = columnVisibility
        self.isInspectorPresented = isInspectorPresented
    }

    public func select(_ tab: TabID) {
        selection = tab
    }

    public func push(_ route: Route, in tab: TabID? = nil) {
        let destinationTab = tab ?? selection
        paths[destinationTab, default: []].append(route)
    }

    @discardableResult
    public func pop(in tab: TabID? = nil) -> Route? {
        let destinationTab = tab ?? selection
        return paths[destinationTab, default: []].popLast()
    }

    public func popToRoot(in tab: TabID? = nil) {
        let destinationTab = tab ?? selection
        paths[destinationTab] = []
    }

    public func replacePath(_ path: [Route], in tab: TabID) {
        paths[tab] = path
    }
}
