import AdaptiveAppShell
import SwiftUI

struct SettingsView: View {
    @Environment(\.adaptiveShellTheme) private var theme

    @Binding var themeID: AdaptiveShellThemeID
    @State private var showProgress = true
    @State private var keepInspectorOpen = true

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                StudioSectionHeader(title: "Appearance")

                VStack(spacing: 12) {
                    ForEach(AdaptiveShellThemeID.allCases) { candidate in
                        themeOption(candidate)
                    }
                }

                StudioSectionHeader(title: "Workspace")

                AdaptiveShellCard(padding: 0) {
                    VStack(spacing: 0) {
                        Toggle("Show project progress", isOn: $showProgress)
                            .padding(16)

                        Divider()
                            .overlay(theme.separator)
                            .padding(.leading, 16)

                        Toggle("Keep inspector open", isOn: $keepInspectorOpen)
                            .padding(16)
                    }
                    .foregroundStyle(theme.primaryText)
                }

                StudioSectionHeader(title: "About this template")

                AdaptiveShellCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Independent navigation history", systemImage: "point.3.connected.trianglepath.dotted")
                        Label("Compact tabs and regular sidebar", systemImage: "rectangle.split.3x1")
                        Label("iOS 26 glass with earlier fallbacks", systemImage: "circle.hexagongrid")
                        Label("Dynamic Type and reduced effects", systemImage: "accessibility")
                    }
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryText)
                }
            }
            .frame(maxWidth: 760, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .background(theme.canvas)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }

    private func themeOption(_ candidate: AdaptiveShellThemeID) -> some View {
        let candidateTheme = AdaptiveShellTheme.preset(candidate)

        return Button {
            themeID = candidate
        } label: {
            HStack(spacing: 14) {
                HStack(spacing: 0) {
                    candidateTheme.sidebarBackground
                    candidateTheme.canvas
                    candidateTheme.accent
                }
                .frame(width: 64, height: 42)
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .stroke(candidateTheme.separator, lineWidth: 0.75)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(candidateTheme.displayName)
                        .font(.headline)
                        .foregroundStyle(theme.primaryText)

                    Text(themeDescription(candidate))
                        .font(.subheadline)
                        .foregroundStyle(theme.secondaryText)
                }

                Spacer()

                Image(systemName: themeID == candidate ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(themeID == candidate ? theme.accent : theme.secondaryText)
            }
            .padding(16)
            .background(theme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(themeID == candidate ? theme.accent : theme.separator, lineWidth: 1)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(themeID == candidate ? .isSelected : [])
    }

    private func themeDescription(_ id: AdaptiveShellThemeID) -> String {
        switch id {
        case .classic:
            "Warm canvas and blue accent"
        case .graphite:
            "Dark neutral workspace"
        case .stone:
            "Muted natural contrast"
        }
    }
}
