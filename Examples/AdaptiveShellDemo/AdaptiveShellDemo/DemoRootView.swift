import AdaptiveAppShell
import SwiftUI
import UIKit

struct DemoRootView: View {
    @State private var shellState: AdaptiveShellState<StudioTab, StudioRoute>
    @State private var themeID: AdaptiveShellThemeID
    @State private var selectedProjectID = StudioFixtures.projects[0].id
    @State private var presentedSheet: StudioSheet?
    @State private var themeSnapshot: UIImage?
    @State private var themeSnapshotOpacity = 0.0
    @State private var themeTransitionID = UUID()

    private let showcaseMode: Bool
    private let profileMode: Bool

    init() {
        let arguments = ProcessInfo.processInfo.arguments
        let initialTab: StudioTab = arguments.contains("--search") ? .search : .overview
        let initialTheme: AdaptiveShellThemeID

        if arguments.contains("--graphite") {
            initialTheme = .graphite
        } else if arguments.contains("--stone") {
            initialTheme = .stone
        } else {
            initialTheme = .classic
        }

        _shellState = State(
            initialValue: AdaptiveShellState<StudioTab, StudioRoute>(
                selection: initialTab,
                columnVisibility: .all,
                isInspectorPresented: arguments.contains("--inspector")
            )
        )
        _themeID = State(initialValue: initialTheme)
        showcaseMode = arguments.contains("--showcase")
        profileMode = arguments.contains("--profile")
    }

    private var theme: AdaptiveShellTheme {
        AdaptiveShellTheme.preset(themeID)
    }

    private var selectedProject: StudioProject {
        StudioFixtures.project(id: selectedProjectID)
    }

    private var themeSelection: Binding<AdaptiveShellThemeID> {
        Binding(
            get: { themeID },
            set: { changeTheme(to: $0) }
        )
    }

    var body: some View {
        AdaptiveAppShell(
            title: "Studio",
            sections: StudioTab.sections,
            state: shellState,
            showsInspector: { item in
                switch item.id {
                case .overview, .projects, .clientWork, .internalWork, .archive:
                    true
                case .activity, .search, .settings:
                    false
                }
            },
            content: { item, navigation in
                StudioTabContent(
                    tab: item.id,
                    navigation: navigation,
                    selectedProjectID: $selectedProjectID,
                    themeID: themeSelection,
                    presentedSheet: $presentedSheet
                )
            },
            destination: { route in
                StudioRouteView(route: route)
            },
            inspector: { _ in
                ProjectInspectorView(project: selectedProject)
            }
        )
        .adaptiveShellTheme(theme)
        .preferredColorScheme(theme.recommendedColorScheme)
        .sheet(item: $presentedSheet) { sheet in
            switch sheet {
            case .newProject:
                NewProjectSheet()
                    .adaptiveShellTheme(theme)
                    .preferredColorScheme(theme.recommendedColorScheme)
            case .profile:
                ProfileSheet()
                    .adaptiveShellTheme(theme)
                    .preferredColorScheme(theme.recommendedColorScheme)
            }
        }
        .onOpenURL(perform: handleDeepLink)
        .overlay {
            if let themeSnapshot {
                Image(uiImage: themeSnapshot)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(themeSnapshotOpacity)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
        }
        .task {
            if profileMode {
                await pause(milliseconds: 300)
                presentedSheet = .profile
            }

            await runShowcaseIfNeeded()
        }
    }

    @MainActor
    private func changeTheme(to newThemeID: AdaptiveShellThemeID) {
        guard newThemeID != themeID else { return }

        guard !UIAccessibility.isReduceMotionEnabled else {
            themeID = newThemeID
            return
        }

        let transitionID = UUID()
        themeTransitionID = transitionID
        themeSnapshot = WindowSnapshot.capture()
        themeSnapshotOpacity = 1
        themeID = newThemeID

        Task { @MainActor in
            await pause(milliseconds: 70)

            guard themeTransitionID == transitionID else { return }

            withAnimation(.easeInOut(duration: 0.52)) {
                themeSnapshotOpacity = 0
            }

            await pause(milliseconds: 560)

            guard themeTransitionID == transitionID else { return }
            themeSnapshot = nil
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "adaptiveshell" else { return }
        let components = url.pathComponents.filter { $0 != "/" }

        if url.host == "project", let id = components.first {
            selectedProjectID = id
            shellState.select(.projects)
            shellState.replacePath([.project(id)], in: .projects)
        } else if url.host == "search" {
            shellState.select(.search)
        }
    }

    @MainActor
    private func runShowcaseIfNeeded() async {
        guard showcaseMode else { return }

        await pause(milliseconds: 900)

        while !Task.isCancelled {
            withAnimation(.easeInOut(duration: 0.28)) {
                shellState.select(.projects)
            }
            await pause(milliseconds: 1_300)

            withAnimation(.easeInOut(duration: 0.28)) {
                selectedProjectID = "website-qa"
                shellState.select(.search)
            }
            await pause(milliseconds: 1_350)

            withAnimation(.easeInOut(duration: 0.28)) {
                shellState.select(.overview)
            }
            await pause(milliseconds: 320)
            changeTheme(to: .graphite)
            await pause(milliseconds: 1_130)

            withAnimation(.easeInOut(duration: 0.28)) {
                shellState.select(.activity)
            }
            await pause(milliseconds: 320)
            changeTheme(to: .stone)
            await pause(milliseconds: 1_030)

            withAnimation(.easeInOut(duration: 0.28)) {
                selectedProjectID = "spring-catalogue"
                shellState.select(.overview)
            }
            await pause(milliseconds: 320)
            changeTheme(to: .classic)
            await pause(milliseconds: 1_130)
        }
    }

    private func pause(milliseconds: UInt64) async {
        try? await Task.sleep(nanoseconds: milliseconds * 1_000_000)
    }
}

@MainActor
private enum WindowSnapshot {
    static func capture() -> UIImage? {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)

        guard let window else { return nil }

        return UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
        }
    }
}

#Preview {
    DemoRootView()
}
