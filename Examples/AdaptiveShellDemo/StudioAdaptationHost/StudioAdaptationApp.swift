import SwiftUI
import UIKit

@main
struct StudioAdaptationApp: App {
    var body: some Scene {
        WindowGroup {
            if let url = launchURL {
                Button("Open demo link") { UIApplication.shared.open(url) }
                    .accessibilityIdentifier("open-demo-link")
            } else {
                StudioAdaptationHarness()
            }
        }
    }

    private var launchURL: URL? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "--open-url"), index + 1 < arguments.count else { return nil }
        return URL(string: arguments[index + 1])
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
