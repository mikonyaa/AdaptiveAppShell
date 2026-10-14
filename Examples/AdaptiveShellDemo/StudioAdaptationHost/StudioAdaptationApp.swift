import SwiftUI

@main
struct StudioAdaptationApp: App {
    var body: some Scene {
        WindowGroup { StudioAdaptationHarness() }
    }
}

private struct StudioAdaptationHarness: View {
    @State private var compact = true

    var body: some View {
        DemoRootView()
            .environment(\.horizontalSizeClass, compact ? .compact : .regular)
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Text(compact ? "Compact presentation" : "Regular presentation")
                        .accessibilityIdentifier("adaptation-mode")
                    Spacer()
                    Button(compact ? "Use regular" : "Use compact") { compact.toggle() }
                }
                .font(.caption)
                .padding(12)
                .background(.regularMaterial)
            }
    }
}
