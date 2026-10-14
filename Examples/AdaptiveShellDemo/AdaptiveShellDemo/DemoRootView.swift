import AdaptiveAppShell
import SwiftUI
import UIKit

struct DemoRootView: View {
    @State private var shellState: AdaptiveShellState<StudioTab, StudioRoute>
    @State private var store: StudioStore
    @State private var coordinator: StudioCoordinator
    @State private var themeID: AdaptiveShellThemeID
    @State private var presentedSheet: StudioSheet?
    @State private var windowReference = StudioWindowReference()
    @State private var themeTransition = StudioThemeTransition()

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

        let state = AdaptiveShellState<StudioTab, StudioRoute>(
            selection: initialTab,
            columnVisibility: .all,
            isInspectorPresented: arguments.contains("--inspector")
        )
        let store = StudioStore()
        store.keepInspectorOpen = arguments.contains("--inspector")
        _shellState = State(initialValue: state)
        _store = State(initialValue: store)
        _coordinator = State(initialValue: StudioCoordinator(store: store, state: state))
        _themeID = State(initialValue: initialTheme)
        showcaseMode = arguments.contains("--showcase")
        profileMode = arguments.contains("--profile")
    }

    private var theme: AdaptiveShellTheme {
        AdaptiveShellTheme.preset(themeID)
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
                if shellState.paths[item.id]?.last != nil { return true }
                switch item.id {
                case .overview, .projects, .clientWork, .internalWork, .archive:
                    return true
                case .activity, .search, .settings:
                    return false
                }
            },
            content: { item, navigation in
                StudioTabContent(
                    tab: item.id,
                    navigation: navigation,
                    store: store,
                    coordinator: coordinator,
                    themeID: themeSelection,
                    presentedSheet: $presentedSheet
                )
            },
            destination: { route in
                StudioRouteView(route: route, store: store)
            },
            inspector: { _ in
                if let project = coordinator.inspectorProject {
                    ProjectInspectorView(project: project, showProgress: store.showProgress)
                } else {
                    StudioEmptyState(
                        title: "No project selected",
                        message: "Open a project to see its details.", systemImage: "folder"
                    )
                }
            }
        )
        .adaptiveShellTheme(theme)
        .preferredColorScheme(theme.recommendedColorScheme)
        .background(StudioWindowReader(reference: windowReference))
        .sheet(item: $presentedSheet) { sheet in
            switch sheet {
            case .newProject:
                NewProjectSheet { name, category, dueDate in
                    guard let project = store.createProject(name: name, category: category, dueDate: dueDate) else {
                        return false
                    }
                    coordinator.openProject(project.id, from: .projects, replacingPath: true)
                    return true
                }
                    .adaptiveShellTheme(theme)
                    .preferredColorScheme(theme.recommendedColorScheme)
            case .profile:
                ProfileSheet()
                    .adaptiveShellTheme(theme)
                    .preferredColorScheme(theme.recommendedColorScheme)
            }
        }
        .onOpenURL(perform: coordinator.handleDeepLink)
        .onChange(of: store.keepInspectorOpen) { _, keepOpen in
            shellState.isInspectorPresented = keepOpen
        }
        .alert(
            coordinator.navigationMessage?.title ?? "Navigation",
            isPresented: Binding(
                get: { coordinator.navigationMessage != nil },
                set: { if !$0 { coordinator.navigationMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) { coordinator.navigationMessage = nil }
        } message: {
            Text(coordinator.navigationMessage?.message ?? "")
        }
        .overlay {
            if let snapshot = themeTransition.snapshot {
                Image(uiImage: snapshot)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(themeTransition.opacity)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
        }
        .onDisappear { themeTransition.cancel() }
        .task {
            do {
                if profileMode {
                    try await pause(milliseconds: 300)
                    presentedSheet = .profile
                }
                try await runShowcaseIfNeeded()
            } catch {
                return
            }
        }
    }

    @MainActor
    private func changeTheme(to newThemeID: AdaptiveShellThemeID) {
        guard newThemeID != themeID else { return }

        guard !UIAccessibility.isReduceMotionEnabled else {
            themeTransition.cancel()
            themeID = newThemeID
            return
        }

        themeTransition.start(in: windowReference.window)
        themeID = newThemeID
    }

    @MainActor
    private func runShowcaseIfNeeded() async throws {
        guard showcaseMode else { return }

        try await pause(milliseconds: 2_600)

        while !Task.isCancelled {
            try await pause(milliseconds: 1_700)

            withAnimation(.easeInOut(duration: 0.28)) {
                shellState.select(.projects)
            }
            try await pause(milliseconds: 1_200)

            withAnimation(.easeInOut(duration: 0.28)) {
                shellState.select(.overview)
            }
            try await pause(milliseconds: 350)

            changeTheme(to: .graphite)
            try await pause(milliseconds: 1_900)

            withAnimation(.easeInOut(duration: 0.28)) {
                shellState.select(.search)
            }
            try await pause(milliseconds: 1_200)

            withAnimation(.easeInOut(duration: 0.28)) {
                shellState.select(.overview)
            }
            try await pause(milliseconds: 350)

            changeTheme(to: .stone)
            try await pause(milliseconds: 1_900)

            withAnimation(.easeInOut(duration: 0.28)) {
                shellState.select(.activity)
            }
            try await pause(milliseconds: 1_200)

            withAnimation(.easeInOut(duration: 0.28)) {
                shellState.select(.overview)
            }
            try await pause(milliseconds: 350)

            changeTheme(to: .classic)
            try await pause(milliseconds: 500)
        }
    }

    private func pause(milliseconds: UInt64) async throws {
        try await Task.sleep(nanoseconds: milliseconds * 1_000_000)
    }
}

#Preview {
    DemoRootView()
}
