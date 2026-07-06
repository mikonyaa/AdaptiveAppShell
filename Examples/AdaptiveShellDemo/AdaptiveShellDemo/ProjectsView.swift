import AdaptiveAppShell
import SwiftUI

struct ProjectsView: View {
    @Environment(\.adaptiveShellTheme) private var theme
    @Environment(\.adaptiveShellPresentation) private var presentation

    let title: String
    let projects: [StudioProject]
    let navigation: AdaptiveShellNavigation<StudioTab, StudioRoute>
    @Binding var selectedProjectID: String

    var body: some View {
        Group {
            if projects.isEmpty {
                StudioEmptyState(
                    title: "No projects",
                    message: "Projects in this collection will appear here.",
                    systemImage: "folder"
                )
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 18) {
                        summary

                        AdaptiveShellCard(padding: 0) {
                            LazyVStack(spacing: 0) {
                                ForEach(projects) { project in
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

                                    if project.id != projects.last?.id {
                                        Divider()
                                            .overlay(theme.separator)
                                            .padding(.leading, 78)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: 820, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .padding(.bottom, 24)
                }
            }
        }
        .background(theme.canvas)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
    }

    private var summary: some View {
        HStack(spacing: 12) {
            summaryItem(
                value: "\(projects.filter { $0.status == .onTrack }.count)",
                label: "On track",
                color: theme.success
            )

            summaryItem(
                value: "\(projects.filter { $0.status == .atRisk }.count)",
                label: "At risk",
                color: theme.warning
            )

            summaryItem(
                value: "\(projects.filter { $0.status == .complete }.count)",
                label: "Complete",
                color: theme.accent
            )
        }
    }

    private func summaryItem(
        value: String,
        label: String,
        color: Color
    ) -> some View {
        AdaptiveShellCard {
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2.weight(.bold).monospacedDigit())
                    .foregroundStyle(theme.primaryText)

                HStack(spacing: 6) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 7))
                        .foregroundStyle(color)

                    Text(label)
                        .font(.caption)
                        .foregroundStyle(theme.secondaryText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
