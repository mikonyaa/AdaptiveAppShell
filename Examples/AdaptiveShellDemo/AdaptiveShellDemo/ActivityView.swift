import AdaptiveAppShell
import SwiftUI

struct ActivityView: View {
    @Environment(\.adaptiveShellTheme) private var theme

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(StudioFixtures.activity) { activity in
                    HStack(alignment: .top, spacing: 14) {
                        Text(activity.initials)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(theme.accent)
                            .frame(width: 42, height: 42)
                            .background(theme.accent.opacity(0.11), in: Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text(activity.title)
                                .font(.body.weight(.medium))
                                .foregroundStyle(theme.primaryText)

                            Text(activity.detail)
                                .font(.subheadline)
                                .foregroundStyle(theme.secondaryText)
                        }

                        Spacer(minLength: 12)

                        Text(activity.time)
                            .font(.caption)
                            .foregroundStyle(theme.secondaryText)
                    }
                    .padding(.vertical, 16)
                    .accessibilityElement(children: .combine)

                    if activity.id != StudioFixtures.activity.last?.id {
                        Divider()
                            .overlay(theme.separator)
                            .padding(.leading, 56)
                    }
                }
            }
            .frame(maxWidth: 760, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .background(theme.canvas)
        .navigationTitle("Activity")
        .navigationBarTitleDisplayMode(.large)
    }
}
