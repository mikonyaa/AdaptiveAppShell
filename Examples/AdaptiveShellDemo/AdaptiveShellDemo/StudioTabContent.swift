import AdaptiveAppShell
import SwiftUI

struct StudioTabContent: View {
    let tab: StudioTab
    let navigation: AdaptiveShellNavigation<StudioTab, StudioRoute>
    let store: StudioStore
    let coordinator: StudioCoordinator
    @Binding var themeID: AdaptiveShellThemeID
    @Binding var presentedSheet: StudioSheet?

    var body: some View {
        Group {
            switch tab {
            case .overview:
                OverviewView(
                    store: store,
                    coordinator: coordinator
                )
            case .projects:
                ProjectsView(
                    title: "Projects",
                    projects: store.projects.filter { $0.collection != .archive },
                    navigation: navigation,
                    store: store,
                    coordinator: coordinator
                )
            case .activity:
                ActivityView()
            case .search:
                StudioSearchView(
                    navigation: navigation,
                    store: store,
                    coordinator: coordinator
                )
            case .settings:
                SettingsView(themeID: $themeID, store: store)
            case .clientWork:
                ProjectsView(
                    title: "Client work",
                    projects: store.projects.filter { $0.collection == .client },
                    navigation: navigation,
                    store: store,
                    coordinator: coordinator
                )
            case .internalWork:
                ProjectsView(
                    title: "Internal",
                    projects: store.projects.filter { $0.collection == .internalWork },
                    navigation: navigation,
                    store: store,
                    coordinator: coordinator
                )
            case .archive:
                ProjectsView(
                    title: "Archive",
                    projects: store.projects.filter { $0.collection == .archive },
                    navigation: navigation,
                    store: store,
                    coordinator: coordinator
                )
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                themeMenu

                Button {
                    presentedSheet = .newProject
                } label: {
                    Label("New project", systemImage: "plus")
                }
                .accessibilityIdentifier("new-project")

                Button {
                    presentedSheet = .profile
                } label: {
                    Text("AM")
                        .font(.caption.weight(.bold))
                        .frame(width: 30, height: 30)
                        .background(.secondary.opacity(0.14), in: Circle())
                }
                .accessibilityLabel("Open profile")
            }
        }
    }

    private var themeMenu: some View {
        Menu {
            Picker("Theme", selection: $themeID) {
                ForEach(AdaptiveShellThemeID.allCases) { id in
                    Label(
                        AdaptiveShellTheme.preset(id).displayName,
                        systemImage: themeID == id ? "checkmark.circle.fill" : "circle"
                    )
                    .tag(id)
                }
            }
        } label: {
            Label("Theme", systemImage: "circle.lefthalf.filled")
        }
        .accessibilityIdentifier("theme-menu")
    }
}

struct StudioRouteView: View {
    let route: StudioRoute
    let store: StudioStore

    var body: some View {
        switch route {
        case .project(let id):
            if let project = store.project(id: id) {
                ProjectDetailView(project: project, store: store)
            } else {
                StudioEmptyState(
                    title: "Project not found", message: "This project is not available in this session.",
                    systemImage: "folder.badge.questionmark"
                )
            }
        case .task(let projectID, let taskID):
            TaskDetailView(projectID: projectID, taskID: taskID, store: store)
        }
    }
}
