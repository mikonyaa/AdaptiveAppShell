import SwiftUI

@MainActor
public struct AdaptiveAppShell<TabID, Route, TabContent, Destination, Inspector>: View where
    TabID: Hashable,
    Route: Hashable,
    TabContent: View,
    Destination: View,
    Inspector: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.adaptiveShellTheme) private var theme

    private let title: String
    private let sections: [AdaptiveShellSection<TabID>]
    private let state: AdaptiveShellState<TabID, Route>
    private let showsInspector: (AdaptiveShellItem<TabID>) -> Bool
    private let content: (AdaptiveShellItem<TabID>, AdaptiveShellNavigation<TabID, Route>) -> TabContent
    private let destination: (Route) -> Destination
    private let inspector: (AdaptiveShellItem<TabID>) -> Inspector

    public init(
        title: String,
        sections: [AdaptiveShellSection<TabID>],
        state: AdaptiveShellState<TabID, Route>,
        showsInspector: @escaping (AdaptiveShellItem<TabID>) -> Bool,
        @ViewBuilder content: @escaping (
            AdaptiveShellItem<TabID>,
            AdaptiveShellNavigation<TabID, Route>
        ) -> TabContent,
        @ViewBuilder destination: @escaping (Route) -> Destination,
        @ViewBuilder inspector: @escaping (AdaptiveShellItem<TabID>) -> Inspector
    ) {
        self.title = title
        self.sections = sections
        self.state = state
        self.showsInspector = showsInspector
        self.content = content
        self.destination = destination
        self.inspector = inspector
    }

    public var body: some View {
        Group {
            if isCompact {
                compactShell
            } else {
                regularShell
            }
        }
        .tint(theme.accent)
        .foregroundStyle(theme.primaryText)
        .background(theme.canvas.ignoresSafeArea())
        .onChange(of: horizontalSizeClass, initial: true) { _, _ in
            normalizeSelection()
        }
        .onChange(of: state.selection) { _, _ in
            normalizeSelection()
        }
    }

    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    private var allItems: [AdaptiveShellItem<TabID>] {
        sections.flatMap(\.items)
    }

    private var compactItems: [AdaptiveShellItem<TabID>] {
        allItems.filter { $0.compactPlacement == .tab }
    }

    private var selectedItem: AdaptiveShellItem<TabID>? {
        allItems.first { $0.id == state.selection }
    }

    private var selectionBinding: Binding<TabID> {
        Binding(
            get: { state.selection },
            set: { state.selection = $0 }
        )
    }

    private var columnVisibilityBinding: Binding<NavigationSplitViewVisibility> {
        Binding(
            get: { state.columnVisibility },
            set: { state.columnVisibility = $0 }
        )
    }

    @ViewBuilder
    private var compactShell: some View {
        if compactItems.isEmpty {
            emptyShell
        } else {
            TabView(selection: selectionBinding) {
                ForEach(compactItems) { item in
                    NavigationStack(path: pathBinding(for: item.id)) {
                        content(item, navigation(for: item.id))
                            .navigationDestination(for: Route.self, destination: destination)
                    }
                    .tabItem {
                        Label(
                            item.title,
                            systemImage: state.selection == item.id
                                ? item.selectedSystemImage
                                : item.systemImage
                        )
                    }
                    .tag(item.id)
                }
            }
            .environment(\.adaptiveShellPresentation, .compact)
            .modifier(CompactTabChrome(theme: theme))
        }
    }

    @ViewBuilder
    private var regularShell: some View {
        if let selectedItem {
            NavigationSplitView(columnVisibility: columnVisibilityBinding) {
                sidebar
                    .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 320)
            } detail: {
                NavigationStack(path: pathBinding(for: selectedItem.id)) {
                    content(selectedItem, navigation(for: selectedItem.id))
                        .navigationDestination(for: Route.self, destination: destination)
                        .toolbar {
                            if showsInspector(selectedItem) {
                                ToolbarItem(placement: .primaryAction) {
                                    inspectorToggle
                                }
                            }
                        }
                }
                .background(theme.canvas)
                .inspector(isPresented: inspectorBinding(for: selectedItem)) {
                    inspector(selectedItem)
                        .inspectorColumnWidth(min: 280, ideal: 330, max: 420)
                }
            }
            .navigationSplitViewStyle(.balanced)
            .environment(\.adaptiveShellPresentation, .regular)
        } else {
            emptyShell
        }
    }

    private var sidebar: some View {
        List {
            ForEach(sections) { section in
                if let sectionTitle = section.title {
                    Section(sectionTitle) {
                        sidebarRows(section.items)
                    }
                } else {
                    Section {
                        sidebarRows(section.items)
                    }
                }
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            HStack {
                Text(title)
                    .font(.title2.weight(.bold))
                Spacer()
            }
            .foregroundStyle(theme.sidebarPrimaryText)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .foregroundStyle(theme.sidebarPrimaryText)
        .background(theme.sidebarBackground)
    }

    private func sidebarRows(_ items: [AdaptiveShellItem<TabID>]) -> some View {
        ForEach(items) { item in
            Button {
                state.selection = item.id
            } label: {
                Label(
                    item.title,
                    systemImage: state.selection == item.id
                        ? item.selectedSystemImage
                        : item.systemImage
                )
                .foregroundStyle(theme.sidebarPrimaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .listRowBackground(
                state.selection == item.id
                    ? theme.sidebarSelectionFill
                    : Color.clear
            )
            .accessibilityAddTraits(state.selection == item.id ? .isSelected : [])
        }
    }

    private var inspectorToggle: some View {
        Button {
            state.isInspectorPresented.toggle()
        } label: {
            Label(
                state.isInspectorPresented ? "Hide inspector" : "Show inspector",
                systemImage: "sidebar.right"
            )
        }
        .accessibilityIdentifier("adaptive-shell-inspector-toggle")
    }

    private var emptyShell: some View {
        ContentUnavailableView(
            "No destinations",
            systemImage: "rectangle.split.3x1",
            description: Text("Add at least one navigation item to the shell.")
        )
    }

    private func pathBinding(for tab: TabID) -> Binding<[Route]> {
        Binding(
            get: { state.paths[tab, default: []] },
            set: { state.paths[tab] = $0 }
        )
    }

    private func inspectorBinding(
        for item: AdaptiveShellItem<TabID>
    ) -> Binding<Bool> {
        Binding(
            get: { showsInspector(item) && state.isInspectorPresented },
            set: { isPresented in
                if showsInspector(item) {
                    state.isInspectorPresented = isPresented
                }
            }
        )
    }

    private func navigation(
        for tab: TabID
    ) -> AdaptiveShellNavigation<TabID, Route> {
        AdaptiveShellNavigation(currentTab: tab, state: state)
    }

    private func normalizeSelection() {
        let candidates = isCompact ? compactItems : allItems
        guard !candidates.isEmpty else { return }
        guard !candidates.contains(where: { $0.id == state.selection }) else { return }
        state.selection = candidates[0].id
    }
}

public extension AdaptiveAppShell where Inspector == EmptyView {
    init(
        title: String,
        sections: [AdaptiveShellSection<TabID>],
        state: AdaptiveShellState<TabID, Route>,
        @ViewBuilder content: @escaping (
            AdaptiveShellItem<TabID>,
            AdaptiveShellNavigation<TabID, Route>
        ) -> TabContent,
        @ViewBuilder destination: @escaping (Route) -> Destination
    ) {
        self.init(
            title: title,
            sections: sections,
            state: state,
            showsInspector: { _ in false },
            content: content,
            destination: destination,
            inspector: { _ in EmptyView() }
        )
    }
}

private struct CompactTabChrome: ViewModifier {
    let theme: AdaptiveShellTheme

    @ViewBuilder
    func body(content: Content) -> some View {
#if os(iOS)
        if #available(iOS 26, *) {
            content
        } else {
            content
                .toolbarBackground(theme.surface, for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
        }
#else
        content
#endif
    }
}
