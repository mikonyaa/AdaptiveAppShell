import SwiftUI

public struct AdaptiveGlassActionButton<Label: View>: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.adaptiveShellTheme) private var theme

    private let action: () -> Void
    private let label: Label

    public init(
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.action = action
        self.label = label()
    }

    public var body: some View {
#if os(iOS) || os(macOS)
        #if compiler(>=6.2)
        if #available(iOS 26, macOS 26, *), !reduceTransparency {
            Button(action: action) {
                label
            }
            .buttonStyle(.glass)
        } else {
            fallbackButton
        }
        #else
        fallbackButton
        #endif
#else
        fallbackButton
#endif
    }

    private var fallbackButton: some View {
        Button(action: action) {
            label
        }
        .buttonStyle(.bordered)
        .tint(theme.accent)
    }
}
