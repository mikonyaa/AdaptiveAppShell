import AdaptiveAppShell
import SwiftUI

struct OverviewView: View {
    @Environment(\.adaptiveShellTheme) private var theme
    @Environment(\.adaptiveShellPresentation) private var presentation

    let store: StudioStore
    let coordinator: StudioCoordinator

    private var activeProjects: [StudioProject] {
        store.projects.filter { $0.collection != .archive }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                morningSummary

                Text("Sample workspace · Session-only data")
                    .font(.footnote)
                    .foregroundStyle(theme.secondaryText)

                StudioSectionHeader(title: "Active projects")

                AdaptiveShellCard(padding: 0) {
                    VStack(spacing: 0) {
                        ForEach(Array(activeProjects.prefix(3))) { project in
                            projectButton(project)

                            if project.id != activeProjects.prefix(3).last?.id {
                                Divider()
                                    .overlay(theme.separator)
                                    .padding(.leading, 78)
                            }
                        }
                    }
                }

                StudioSectionHeader(title: "Upcoming")

                AdaptiveShellCard(padding: 0) {
                    VStack(spacing: 0) {
                        ForEach(store.upcomingTasks) { result in
                            Button {
                                coordinator.openProject(
                                    result.project.id, from: .overview, presentation: presentation
                                )
                            } label: {
                                upcomingRow(result)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("upcoming-project-\(result.project.id)")
                            .accessibilityHint("Opens project details")
                            if result.id != store.upcomingTasks.last?.id {
                                Divider().overlay(theme.separator).padding(.leading, 70)
                            }
                        }
                        if store.upcomingTasks.isEmpty {
                            Text("No upcoming tasks.").foregroundStyle(theme.secondaryText).padding(16)
                        }
                    }
                }
            }
            .frame(maxWidth: 820, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .background(theme.canvas)
        .navigationTitle("Overview")
        .navigationBarTitleDisplayMode(.large)
    }

    private var morningSummary: some View {
        AdaptiveShellCard {
            HStack(spacing: 14) {
                Image(systemName: "sun.max.fill")
                    .font(.title2)
                    .foregroundStyle(theme.warning)
                    .frame(width: 44, height: 44)
                    .background(theme.warning.opacity(0.10), in: Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text("Good morning")
                        .font(.headline)
                        .foregroundStyle(theme.primaryText)

                    Text("\(activeProjects.filter { $0.progress < 1 }.count) active projects")
                        .font(.subheadline)
                        .foregroundStyle(theme.secondaryText)
                }

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.accent)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func projectButton(_ project: StudioProject) -> some View {
        Button {
            coordinator.openProject(project.id, from: .overview, presentation: presentation)
        } label: {
            ProjectRow(project: project, showProgress: store.showProgress)
                .padding(16)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("project-\(project.id)")
    }

    private func upcomingRow(_ result: StudioTaskResult) -> some View {
        let dateParts = result.task.dueText.split(separator: " ")
        return HStack(spacing: 14) {
            VStack(spacing: 0) {
                Text(dateParts.first.map(String.init) ?? "—")
                    .font(.subheadline.weight(.bold).monospacedDigit())
                Text(dateParts.dropFirst().first.map { $0.uppercased() } ?? "")
                    .font(.caption2.weight(.bold))
            }
                .foregroundStyle(theme.accent)
                .frame(width: 40, height: 40)
                .background(theme.accent.opacity(0.10), in: RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(result.project.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.primaryText)

                Text(result.task.title)
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(theme.secondaryText.opacity(0.7))
        }
        .padding(16)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}
