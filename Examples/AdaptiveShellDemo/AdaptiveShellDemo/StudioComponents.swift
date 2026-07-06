import AdaptiveAppShell
import SwiftUI

struct StudioSectionHeader: View {
    @Environment(\.adaptiveShellTheme) private var theme

    let title: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(theme.primaryText)

            Spacer()

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.subheadline.weight(.semibold))
            }
        }
    }
}

struct ProjectIcon: View {
    @Environment(\.adaptiveShellTheme) private var theme

    let project: StudioProject

    var body: some View {
        Image(systemName: project.systemImage)
            .font(.title3.weight(.semibold))
            .foregroundStyle(iconColor)
            .frame(width: 48, height: 48)
            .background(iconColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            .accessibilityHidden(true)
    }

    private var iconColor: Color {
        switch project.status {
        case .onTrack:
            theme.accent
        case .atRisk:
            theme.warning
        case .complete:
            theme.success
        }
    }
}

struct ProjectProgressBar: View {
    @Environment(\.adaptiveShellTheme) private var theme

    let progress: Double

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(theme.separator)

                Capsule()
                    .fill(theme.accent)
                    .frame(width: max(4, proxy.size.width * progress))
            }
        }
        .frame(height: 5)
        .accessibilityElement()
        .accessibilityLabel("Progress")
        .accessibilityValue(progress.formatted(.percent.precision(.fractionLength(0))))
    }
}

struct ProjectStatusBadge: View {
    @Environment(\.adaptiveShellTheme) private var theme

    let status: StudioProjectStatus

    var body: some View {
        Label(status.rawValue, systemImage: "circle.fill")
            .font(.caption.weight(.medium))
            .foregroundStyle(color)
            .labelStyle(CompactStatusLabelStyle())
    }

    private var color: Color {
        switch status {
        case .onTrack:
            theme.success
        case .atRisk:
            theme.warning
        case .complete:
            theme.success
        }
    }
}

private struct CompactStatusLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 6) {
            configuration.icon
                .font(.system(size: 7))
            configuration.title
        }
    }
}

struct OwnerStack: View {
    @Environment(\.adaptiveShellTheme) private var theme

    let initials: [String]

    var body: some View {
        HStack(spacing: -8) {
            ForEach(initials, id: \.self) { initials in
                Text(initials)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(theme.primaryText)
                    .frame(width: 30, height: 30)
                    .background(theme.elevatedSurface, in: Circle())
                    .overlay {
                        Circle()
                            .stroke(theme.canvas, lineWidth: 2)
                    }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Owners: \(initials.joined(separator: ", "))")
    }
}

struct ProjectRow: View {
    @Environment(\.adaptiveShellTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let project: StudioProject

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            accessibilityLayout
        } else {
            standardLayout
        }
    }

    private var standardLayout: some View {
        HStack(spacing: 14) {
            ProjectIcon(project: project)

            VStack(alignment: .leading, spacing: 7) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(project.name)
                        .font(.headline)
                        .foregroundStyle(theme.primaryText)

                    Spacer(minLength: 8)

                    Text(project.progress.formatted(.percent.precision(.fractionLength(0))))
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(theme.secondaryText)
                }

                Text("\(project.category) · \(project.dueText)")
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryText)

                HStack(spacing: 12) {
                    ProjectProgressBar(progress: project.progress)
                        .frame(maxWidth: 170)

                    ProjectStatusBadge(status: project.status)

                    Spacer(minLength: 0)

                    OwnerStack(initials: project.ownerInitials)
                }
            }

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(theme.secondaryText.opacity(0.75))
                .accessibilityHidden(true)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens project details")
    }

    private var accessibilityLayout: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                ProjectIcon(project: project)

                Text(project.name)
                    .font(.headline)
                    .foregroundStyle(theme.primaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.secondaryText.opacity(0.75))
                    .padding(.top, 8)
                    .accessibilityHidden(true)
            }

            Text("\(project.category) · \(project.dueText)")
                .font(.subheadline)
                .foregroundStyle(theme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            ProjectProgressBar(progress: project.progress)

            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(project.progress.formatted(.percent.precision(.fractionLength(0))))
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(theme.secondaryText)

                ProjectStatusBadge(status: project.status)
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens project details")
    }
}

struct StudioEmptyState: View {
    @Environment(\.adaptiveShellTheme) private var theme

    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        ContentUnavailableView(
            title,
            systemImage: systemImage,
            description: Text(message)
        )
        .foregroundStyle(theme.primaryText)
    }
}
