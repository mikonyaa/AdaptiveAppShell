import AdaptiveAppShell
import SwiftUI

struct StudioSearchView: View {
    @Environment(\.adaptiveShellTheme) private var theme
    @Environment(\.adaptiveShellPresentation) private var presentation

    let navigation: AdaptiveShellNavigation<StudioTab, StudioRoute>
    @Bindable var store: StudioStore
    let coordinator: StudioCoordinator

    var body: some View {
        let results = store.searchResults
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 22) {
                if results.isEmpty {
                    StudioEmptyState(
                        title: "No results", message: "Try another name or a broader search scope.",
                        systemImage: "magnifyingglass"
                    )
                    .accessibilityIdentifier("search-empty")
                } else {
                    resultSections(results)
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
            text: $store.searchQuery,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Projects, tasks, or people"
        )
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .searchScopes($store.searchScope, activation: .onSearchPresentation) {
            ForEach(StudioSearchScope.allCases) { scope in
                Text(scope.rawValue).tag(scope)
            }
        }
    }

    @ViewBuilder
    private func resultSections(_ results: StudioSearchResults) -> some View {
        if !results.projects.isEmpty {
            StudioSectionHeader(title: "Projects")
            AdaptiveShellCard(padding: 0) {
                VStack(spacing: 0) {
                    ForEach(results.projects) { project in
                        Button {
                            coordinator.openProject(project.id, from: .search, presentation: presentation)
                        } label: {
                            ProjectRow(project: project, showProgress: store.showProgress).padding(16)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("project-\(project.id)")
                        if project.id != results.projects.last?.id {
                            Divider().overlay(theme.separator).padding(.leading, 78)
                        }
                    }
                }
            }
        }

        if !results.tasks.isEmpty {
            StudioSectionHeader(title: "Tasks")
            AdaptiveShellCard(padding: 0) {
                VStack(spacing: 0) {
                    ForEach(results.tasks) { result in
                        taskResult(result, query: results.query)
                        if result.id != results.tasks.last?.id {
                            Divider().overlay(theme.separator).padding(.leading, 54)
                        }
                    }
                }
            }
        }

        if !results.people.isEmpty {
            StudioSectionHeader(title: "People")
            ForEach(results.people) { person in
                personResult(person)
            }
        }
    }

    private func personResult(_ person: StudioPerson) -> some View {
        AdaptiveShellCard {
            HStack(spacing: 14) {
                Text(person.id).font(.headline).foregroundStyle(theme.accent)
                    .frame(width: 46, height: 46)
                    .background(theme.accent.opacity(0.12), in: Circle())
                VStack(alignment: .leading, spacing: 3) {
                    Text(person.name).font(.headline).foregroundStyle(theme.primaryText)
                    Text(person.role).font(.subheadline).foregroundStyle(theme.secondaryText)
                }
                Spacer()
            }
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("search-person-\(person.id)")
        }
    }

    private func taskResult(_ result: StudioTaskResult, query: String) -> some View {
        Button {
            navigation.push(.task(projectID: result.project.id, taskID: result.task.id))
        } label: {
            HStack(spacing: 14) {
                Image(systemName: result.task.isComplete ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundStyle(result.task.isComplete ? theme.success : theme.secondaryText)
                VStack(alignment: .leading, spacing: 3) {
                    highlightedText(result.task.title, query: query).font(.body.weight(.medium))
                    Text("\(result.project.name) · \(result.task.dueText)")
                        .font(.subheadline).foregroundStyle(theme.secondaryText)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.caption.weight(.bold))
                    .foregroundStyle(theme.secondaryText)
            }
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("search-task-\(result.id)")
        .accessibilityHint("Opens task details")
    }

    private func highlightedText(_ text: String, query: String) -> Text {
        guard !query.isEmpty, let range = text.range(of: query, options: .caseInsensitive) else {
            return Text(text).foregroundColor(theme.primaryText)
        }
        return Text(String(text[..<range.lowerBound])).foregroundColor(theme.primaryText)
            + Text(String(text[range])).bold().foregroundColor(theme.accent)
            + Text(String(text[range.upperBound...])).foregroundColor(theme.primaryText)
    }
}
