import AdaptiveAppShell
import SwiftUI

private enum StudioSearchScope: String, CaseIterable, Identifiable {
    case all = "All"
    case projects = "Projects"
    case tasks = "Tasks"
    case people = "People"

    var id: String { rawValue }
}

struct StudioSearchView: View {
    @Environment(\.adaptiveShellTheme) private var theme
    @Environment(\.adaptiveShellPresentation) private var presentation

    let navigation: AdaptiveShellNavigation<StudioTab, StudioRoute>
    @Binding var selectedProjectID: String

    @State private var query = "website"
    @State private var scope = StudioSearchScope.all

    private var matchingProjects: [StudioProject] {
        StudioFixtures.projects.filter {
            query.isEmpty
                || $0.name.localizedCaseInsensitiveContains(query)
                || $0.category.localizedCaseInsensitiveContains(query)
        }
    }

    private var matchingTasks: [(StudioProject, StudioTask)] {
        StudioFixtures.projects.flatMap { project in
            project.tasks.compactMap { task in
                let matches = query.isEmpty
                    || task.title.localizedCaseInsensitiveContains(query)
                    || project.name.localizedCaseInsensitiveContains(query)
                return matches ? (project, task) : nil
            }
        }
    }

    private var showsProjects: Bool {
        scope == .all || scope == .projects
    }

    private var showsTasks: Bool {
        scope == .all || scope == .tasks
    }

    private var showsPeople: Bool {
        scope == .all || scope == .people
    }

    private var personMatches: Bool {
        query.isEmpty
            || "Sam Campbell".localizedCaseInsensitiveContains(query)
            || "Designer".localizedCaseInsensitiveContains(query)
            || "Website QA".localizedCaseInsensitiveContains(query)
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 22) {
                if query.isEmpty {
                    recentProjects
                } else if matchingProjects.isEmpty
                    && matchingTasks.isEmpty
                    && !(showsPeople && personMatches) {
                    StudioEmptyState(
                        title: "No results",
                        message: "Try another name or a broader search scope.",
                        systemImage: "magnifyingglass"
                    )
                } else {
                    resultSections
                }
            }
            .frame(maxWidth: 780, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .background(theme.canvas)
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.large)
        .searchable(
            text: $query,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Projects, tasks, or people"
        )
        .searchScopes($scope) {
            ForEach(StudioSearchScope.allCases) { scope in
                Text(scope.rawValue)
                    .tag(scope)
            }
        }
    }

    @ViewBuilder
    private var resultSections: some View {
        if showsProjects, !matchingProjects.isEmpty {
            StudioSectionHeader(title: "Projects")

            AdaptiveShellCard(padding: 0) {
                VStack(spacing: 0) {
                    ForEach(matchingProjects) { project in
                        projectResult(project)

                        if project.id != matchingProjects.last?.id {
                            Divider()
                                .overlay(theme.separator)
                                .padding(.leading, 78)
                        }
                    }
                }
            }
        }

        if showsTasks, !matchingTasks.isEmpty {
            StudioSectionHeader(title: "Tasks")

            AdaptiveShellCard(padding: 0) {
                VStack(spacing: 0) {
                    ForEach(matchingTasks, id: \.1.id) { project, task in
                        Button {
                            navigation.push(.task(task.id))
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: task.isComplete ? "checkmark.square.fill" : "square")
                                    .font(.title3)
                                    .foregroundStyle(task.isComplete ? theme.success : theme.secondaryText)

                                VStack(alignment: .leading, spacing: 3) {
                                    highlightedText(task.title)
                                        .font(.body.weight(.medium))

                                    Text("\(project.name) · \(task.dueText)")
                                        .font(.subheadline)
                                        .foregroundStyle(theme.secondaryText)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(theme.secondaryText)
                            }
                            .padding(16)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if task.id != matchingTasks.last?.1.id {
                            Divider()
                                .overlay(theme.separator)
                                .padding(.leading, 54)
                        }
                    }
                }
            }
        }

        if showsPeople, personMatches {
            StudioSectionHeader(title: "People")

            AdaptiveShellCard {
                HStack(spacing: 14) {
                    Text("SC")
                        .font(.headline)
                        .foregroundStyle(theme.accent)
                        .frame(width: 46, height: 46)
                        .background(theme.accent.opacity(0.12), in: Circle())

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Sam Campbell")
                            .font(.headline)
                            .foregroundStyle(theme.primaryText)

                        Text("Designer · Website QA")
                            .font(.subheadline)
                            .foregroundStyle(theme.secondaryText)
                    }

                    Spacer()
                }
                .accessibilityElement(children: .combine)
            }
        }
    }

    private var recentProjects: some View {
        Group {
            StudioSectionHeader(title: "Recent projects")

            AdaptiveShellCard(padding: 0) {
                VStack(spacing: 0) {
                    ForEach(Array(StudioFixtures.projects.prefix(3))) { project in
                        projectResult(project)
                    }
                }
            }
        }
    }

    private func projectResult(_ project: StudioProject) -> some View {
        Button {
            selectedProjectID = project.id
            if presentation == .compact {
                navigation.push(.project(project.id))
            }
        } label: {
            ProjectRow(project: project)
                .padding(16)
        }
        .buttonStyle(.plain)
    }

    private func highlightedText(_ text: String) -> Text {
        guard !query.isEmpty,
              let range = text.range(of: query, options: .caseInsensitive) else {
            return Text(text).foregroundColor(theme.primaryText)
        }

        let prefix = String(text[..<range.lowerBound])
        let match = String(text[range])
        let suffix = String(text[range.upperBound...])

        return Text(prefix).foregroundColor(theme.primaryText)
            + Text(match).bold().foregroundColor(theme.accent)
            + Text(suffix).foregroundColor(theme.primaryText)
    }
}
