import AdaptiveAppShell
import Foundation
import Observation

enum StudioDeepLink: Equatable {
    case project(String)
    case search
    case invalid

    static func parse(_ url: URL) -> Self {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.scheme?.lowercased() == "adaptiveshell",
              components.user == nil, components.password == nil, components.port == nil,
              components.query == nil, components.fragment == nil else { return .invalid }
        switch components.host?.lowercased() {
        case "project":
            let path = components.percentEncodedPath
            guard path.hasPrefix("/"),
                  let id = String(path.dropFirst()).removingPercentEncoding,
                  !id.isEmpty, !id.contains("/"),
                  id == id.trimmingCharacters(in: .whitespacesAndNewlines) else { return .invalid }
            return .project(id)
        case "search" where components.path.isEmpty || components.path == "/":
            return .search
        default:
            return .invalid
        }
    }
}

struct StudioNavigationMessage: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

@MainActor
@Observable
final class StudioCoordinator {
    let store: StudioStore
    let state: AdaptiveShellState<StudioTab, StudioRoute>
    private(set) var selectedProjectID: String?
    var navigationMessage: StudioNavigationMessage?

    init(store: StudioStore, state: AdaptiveShellState<StudioTab, StudioRoute>) {
        self.store = store
        self.state = state
        selectedProjectID = store.projects.first?.id
    }

    var inspectorProject: StudioProject? {
        if let route = state.paths[state.selection]?.last {
            switch route {
            case .project(let id):
                return store.project(id: id)
            case .task(let projectID, _):
                return store.project(id: projectID)
            }
        }
        return selectedProjectID.flatMap { store.project(id: $0) }
    }

    @discardableResult
    func openProject(
        _ id: String,
        from source: StudioTab,
        presentation: AdaptiveShellPresentation = .regular,
        replacingPath: Bool = false
    ) -> Bool {
        guard store.project(id: id) != nil else {
            navigationMessage = StudioNavigationMessage(
                title: "Project not found", message: "This project is not available in this demo session."
            )
            return false
        }
        let tab = presentation == .compact && source.isCollection ? StudioTab.projects : source
        selectedProjectID = id
        state.select(tab)
        if replacingPath {
            state.replacePath([.project(id)], in: tab)
        } else if state.paths[tab]?.last != .project(id) {
            state.push(.project(id), in: tab)
        }
        if store.keepInspectorOpen { state.isInspectorPresented = true }
        return true
    }

    func handleDeepLink(_ url: URL) {
        switch StudioDeepLink.parse(url) {
        case .project(let id):
            openProject(id, from: .projects, replacingPath: true)
        case .search:
            state.select(.search)
        case .invalid:
            navigationMessage = StudioNavigationMessage(
                title: "Invalid link", message: "Use adaptiveshell://project/<id> or adaptiveshell://search."
            )
        }
    }
}
