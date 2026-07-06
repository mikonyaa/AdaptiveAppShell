import AdaptiveAppShell
import SwiftUI

struct StudioTabContent: View {
    let tab: StudioTab
    let navigation: AdaptiveShellNavigation<StudioTab, StudioRoute>
    @Binding var selectedProjectID: String
    @Binding var themeID: AdaptiveShellThemeID
    @Binding var presentedSheet: StudioSheet?

    var body: some View {
        Group {
            switch tab {
            case .overview:
                OverviewView(
                    navigation: navigation,
                    selectedProjectID: $selectedProjectID
                )
            case .projects:
                ProjectsView(
                    title: "Projects",
                    projects: StudioFixtures.projects.filter { $0.collection != .archive },
                    navigation: navigation,
                    selectedProjectID: $selectedProjectID
                )
            case .activity:
                ActivityView()
            case .search:
                StudioSearchView(
                    navigation: navigation,
                    selectedProjectID: $selectedProjectID
                )
            case .settings:
                SettingsView(themeID: $themeID)
            case .clientWork:
                ProjectsView(
                    title: "Client work",
                    projects: StudioFixtures.projects.filter { $0.collection == .client },
                    navigation: navigation,
                    selectedProjectID: $selectedProjectID
                )
            case .internalWork:
                ProjectsView(
                    title: "Internal",
                    projects: StudioFixtures.projects.filter { $0.collection == .internalWork },
                    navigation: navigation,
                    selectedProjectID: $selectedProjectID
                )
            case .archive:
                ProjectsView(
                    title: "Archive",
                    projects: StudioFixtures.projects.filter { $0.collection == .archive },
                    navigation: navigation,
                    selectedProjectID: $selectedProjectID
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

    var body: some View {
        switch route {
        case .project(let id):
            ProjectDetailView(project: StudioFixtures.project(id: id))
        case .task(let id):
            TaskDetailView(taskID: id)
        }
    }
}
