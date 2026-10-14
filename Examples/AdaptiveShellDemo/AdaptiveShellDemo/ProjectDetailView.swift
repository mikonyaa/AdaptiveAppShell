import AdaptiveAppShell
import SwiftUI

struct ProjectDetailView: View {
    @Environment(\.adaptiveShellTheme) private var theme

    let project: StudioProject
    let store: StudioStore

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                header

                AdaptiveShellCard {
                    VStack(alignment: .leading, spacing: 14) {
                        if store.showProgress {
                            HStack {
                                Text("Progress")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(theme.primaryText)

                                Spacer()

                                Text(project.progress.formatted(.percent.precision(.fractionLength(0))))
                                    .font(.subheadline.monospacedDigit())
                                    .foregroundStyle(theme.secondaryText)
                                    .accessibilityIdentifier("detail-progress")
                            }

                            ProjectProgressBar(progress: project.progress)
                        }

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

                if project.tasks.isEmpty {
                    Text("No tasks in this project yet.").font(.subheadline).foregroundStyle(theme.secondaryText)
                }

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
        .accessibilityIdentifier("project-detail-\(project.id)")
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
            store.toggleTask(task.id, in: project.id)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: task.isComplete ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundStyle(task.isComplete ? theme.success : theme.secondaryText)

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
        .accessibilityValue(task.isComplete ? "Complete" : "Incomplete")
        .accessibilityHint("Toggles task completion")
        .accessibilityIdentifier("task-\(project.id)-\(task.id)")
    }
}

struct ProjectInspectorView: View {
    @Environment(\.adaptiveShellTheme) private var theme

    let project: StudioProject
    var showProgress = true
    let onClose: () -> Void

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
                    Spacer(minLength: 0)
                    Button(role: .cancel, action: onClose) {
                        Image(systemName: "xmark")
                            .font(.body.weight(.semibold))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(theme.secondaryText)
                    .accessibilityLabel("Close inspector")
                    .accessibilityIdentifier("inspector-close")
                }

                Divider()
                    .overlay(theme.separator)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Project details")
                        .font(.headline)
                        .foregroundStyle(theme.primaryText)

                    if showProgress { ProjectProgressBar(progress: project.progress) }

                    HStack {
                        ProjectStatusBadge(status: project.status)
                        Spacer()
                        if showProgress {
                            Text(project.progress.formatted(.percent.precision(.fractionLength(0))))
                                .font(.subheadline.monospacedDigit())
                                .foregroundStyle(theme.secondaryText)
                                .accessibilityIdentifier("inspector-progress")
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Owners")
                        .font(.headline)
                        .foregroundStyle(theme.primaryText)

                    ForEach(project.ownerInitials, id: \.self) { initials in
                        if let person = StudioFixtures.people.first(where: { $0.id == initials }) {
                            ownerRow(initials: initials, name: person.name, role: person.role)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Next deadline")
                        .font(.headline)
                        .foregroundStyle(theme.primaryText)

                    Label(project.tasks.first(where: { !$0.isComplete }).map {
                        "\($0.title) · \($0.dueText)"
                    } ?? project.dueText, systemImage: "calendar")
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
        .accessibilityIdentifier("project-inspector-\(project.id)")
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

    let projectID: String
    let taskID: String
    let store: StudioStore

    var body: some View {
        Group {
            if let project = store.project(id: projectID), let task = project.tasks.first(where: { $0.id == taskID }) {
                VStack(alignment: .leading, spacing: 18) {
                    Text(task.title).font(.title2.bold())
                        .accessibilityIdentifier("task-detail-\(projectID)-\(taskID)")
                    Text("\(project.name) · \(task.dueText)").foregroundStyle(theme.secondaryText)
                    Button(task.isComplete ? "Mark incomplete" : "Mark complete") {
                        store.toggleTask(taskID, in: projectID)
                    }
                    .accessibilityValue(task.isComplete ? "Complete" : "Incomplete")
                    .accessibilityIdentifier("task-detail-toggle")
                }
                .padding(24)
            } else {
                StudioEmptyState(
                    title: "Task not found",
                    message: "This task is not available in this session.", systemImage: "checklist"
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.canvas)
        .navigationTitle("Task")
    }
}
