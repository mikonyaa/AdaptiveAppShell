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
        if #available(iOS 26, macOS 26, *), !reduceTransparency {
            Button(action: action) {
                label
            }
            .buttonStyle(.glass)
        } else {
            Button(action: action) {
                label
            }
            .buttonStyle(.bordered)
            .tint(theme.accent)
        }
    }
}
