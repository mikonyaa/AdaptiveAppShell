import AdaptiveAppShell
import SwiftUI

struct OverviewView: View {
    @Environment(\.adaptiveShellTheme) private var theme
    @Environment(\.adaptiveShellPresentation) private var presentation

    let navigation: AdaptiveShellNavigation<StudioTab, StudioRoute>
    @Binding var selectedProjectID: String

    private let activeProjects = StudioFixtures.projects.filter {
        $0.collection != .archive
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                morningSummary

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
                        upcomingRow(
                            day: "10",
                            month: "JUL",
                            title: "Spring catalogue",
                            subtitle: "Copy review"
                        )

                        Divider()
                            .overlay(theme.separator)
                            .padding(.leading, 70)

                        upcomingRow(
                            day: "18",
                            month: "JUL",
                            title: "Website QA",
                            subtitle: "Usability testing"
                        )
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

                    Text("3 projects need attention")
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

    private func upcomingRow(
        day: String,
        month: String,
        title: String,
        subtitle: String
    ) -> some View {
        HStack(spacing: 14) {
            VStack(spacing: 0) {
                Text(day)
                    .font(.subheadline.weight(.bold).monospacedDigit())
                Text(month)
                    .font(.caption2.weight(.bold))
            }
                .foregroundStyle(theme.accent)
                .frame(width: 40, height: 40)
                .background(theme.accent.opacity(0.10), in: RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.primaryText)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(theme.secondaryText.opacity(0.7))
        }
        .padding(16)
        .accessibilityElement(children: .combine)
    }
}
