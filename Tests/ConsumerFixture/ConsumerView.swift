import AdaptiveAppShell
import SwiftUI

public struct ConsumerView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var state = AdaptiveShellState<String, String>(selection: "alpha")
    @State private var items = Self.initialItems
    @State private var compactOverride: Bool?

    private var compact: Bool { compactOverride ?? (sizeClass == .compact) }

    public init() {}

    private static let initialItems = [
        AdaptiveShellItem(id: "alpha", title: "Alpha", systemImage: "a.circle"),
        AdaptiveShellItem(id: "beta", title: "Beta", systemImage: "b.circle")
    ]

    public var body: some View {
        AdaptiveAppShell(
            title: "Public consumer",
            sections: items.enumerated().map { index, item in
                AdaptiveShellSection(id: "section-\(index)", items: [item])
            },
            state: state,
            content: { item, navigation in
                VStack(spacing: 24) {
                    Text("Root \(item.title)")
                        .accessibilityIdentifier("consumer-root-\(item.id)")
                    Button("Open \(item.title) detail") { navigation.push(item.id) }
                }
                .navigationTitle(item.title)
            },
            destination: { route in
                Text("Detail \(route)")
                    .accessibilityIdentifier("consumer-detail-\(route)")
                    .navigationTitle("Detail \(route)")
            }
        )
        .environment(\.horizontalSizeClass, compact ? .compact : .regular)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 6) {
                HStack {
                    Menu("Configuration") {
                        Button("Remove selected") { items.removeAll { $0.id == state.selection } }
                        Button("Clear sections") { items = [] }
                        Button("Load sections") { items = Self.initialItems }
                        Button("Remove other") { items.removeAll { $0.id != state.selection } }
                        Button("Reverse order") { items.reverse() }
                        Button("Hide Alpha") {
                            items = [
                                AdaptiveShellItem(
                                    id: "alpha", title: "Alpha", systemImage: "a.circle", compactPlacement: .hidden
                                ),
                                Self.initialItems[1]
                            ]
                        }
                        Button("Duplicate Alpha") { items.append(Self.initialItems[0]) }
                    }
                    Button("Select Alpha") { state.select("alpha") }
                    Button("Select Beta") { state.select("beta") }
                }
                Button(compact ? "Use regular" : "Use compact") { compactOverride = !compact }
                Text("Selection: \(state.selection)")
                    .accessibilityIdentifier("consumer-selection")
            }
            .font(.caption)
            .padding(8)
            .background(.regularMaterial)
        }
    }
}
