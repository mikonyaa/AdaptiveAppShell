import AdaptiveAppShell
import SwiftUI

struct ProjectDetailView: View {
    @Environment(\.adaptiveShellTheme) private var theme

    let project: StudioProject
    @State private var completedTaskIDs: Set<String>

    init(project: StudioProject) {
        self.project = project
        _completedTaskIDs = State(
            initialValue: Set(project.tasks.filter(\.isComplete).map(\.id))
        )
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                header

                AdaptiveShellCard {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Progress")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(theme.primaryText)

                            Spacer()

                            Text(project.progress.formatted(.percent.precision(.fractionLength(0))))
                                .font(.subheadline.monospacedDigit())
                                .foregroundStyle(theme.secondaryText)
                        }

                        ProjectProgressBar(progress: project.progress)

                        HStack {
                            ProjectStatusBadge(status: project.status)
                            Spacer()
                            Text(project.dueText)
                                .font(.subheadline)
                                .foregroundStyle(theme.secondaryText)
                        }
                    }
                }

                StudioSectionHeader(title: "Tasks")

                AdaptiveShellCard(padding: 0) {
                    VStack(spacing: 0) {
                        ForEach(project.tasks) { task in
                            taskRow(task)

                            if task.id != project.tasks.last?.id {
                                Divider()
                                    .overlay(theme.separator)
                                    .padding(.leading, 52)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: 760, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .background(theme.canvas)
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack(spacing: 16) {
            ProjectIcon(project: project)

            VStack(alignment: .leading, spacing: 4) {
                Text(project.name)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(theme.primaryText)

                Text(project.category)
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryText)
            }

            Spacer()

            OwnerStack(initials: project.ownerInitials)
        }
    }

    private func taskRow(_ task: StudioTask) -> some View {
        Button {
            if completedTaskIDs.contains(task.id) {
                completedTaskIDs.remove(task.id)
            } else {
                completedTaskIDs.insert(task.id)
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: completedTaskIDs.contains(task.id) ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundStyle(completedTaskIDs.contains(task.id) ? theme.success : theme.secondaryText)

                Text(task.title)
                    .foregroundStyle(theme.primaryText)

                Spacer()

                Text(task.dueText)
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryText)
            }
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityValue(completedTaskIDs.contains(task.id) ? "Complete" : "Incomplete")
    }
}

struct ProjectInspectorView: View {
    @Environment(\.adaptiveShellTheme) private var theme

    let project: StudioProject

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack(spacing: 14) {
                    ProjectIcon(project: project)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(project.name)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(theme.primaryText)

                        Text(project.category)
                            .font(.subheadline)
                            .foregroundStyle(theme.secondaryText)
                    }
                }

                Divider()
                    .overlay(theme.separator)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Project details")
                        .font(.headline)
                        .foregroundStyle(theme.primaryText)

                    ProjectProgressBar(progress: project.progress)

                    HStack {
                        ProjectStatusBadge(status: project.status)
                        Spacer()
                        Text(project.progress.formatted(.percent.precision(.fractionLength(0))))
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(theme.secondaryText)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Owners")
                        .font(.headline)
                        .foregroundStyle(theme.primaryText)

                    ownerRow(initials: "AM", name: "Alex Morgan", role: "Design Director")
                    ownerRow(initials: "NW", name: "Noah Williams", role: "Art Director")
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Next deadline")
                        .font(.headline)
                        .foregroundStyle(theme.primaryText)

                    Label("Print proof · 14 Jul", systemImage: "calendar")
                        .font(.subheadline)
                        .foregroundStyle(theme.secondaryText)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Tasks")
                        .font(.headline)
                        .foregroundStyle(theme.primaryText)

                    ForEach(project.tasks.prefix(5)) { task in
                        Label(
                            task.title,
                            systemImage: task.isComplete ? "checkmark.circle.fill" : "circle"
                        )
                        .font(.subheadline)
                        .foregroundStyle(task.isComplete ? theme.success : theme.primaryText)
                    }
                }
            }
            .padding(20)
        }
        .background(theme.surface)
    }

    private func ownerRow(
        initials: String,
        name: String,
        role: String
    ) -> some View {
        HStack(spacing: 10) {
            Text(initials)
                .font(.caption.weight(.bold))
                .foregroundStyle(theme.accent)
                .frame(width: 36, height: 36)
                .background(theme.accent.opacity(0.11), in: Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(theme.primaryText)

                Text(role)
                    .font(.caption)
                    .foregroundStyle(theme.secondaryText)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct TaskDetailView: View {
    @Environment(\.adaptiveShellTheme) private var theme

    let taskID: String

    var body: some View {
        StudioEmptyState(
            title: "Task details",
            message: "Selected task: \(taskID)",
            systemImage: "checklist"
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.canvas)
        .navigationTitle("Task")
    }
}
