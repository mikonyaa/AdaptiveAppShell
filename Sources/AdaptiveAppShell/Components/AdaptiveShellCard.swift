import SwiftUI

public struct AdaptiveShellCard<Content: View>: View {
    @Environment(\.adaptiveShellTheme) private var theme

    private let padding: CGFloat
    private let content: Content

    public init(
        padding: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .background(theme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(theme.separator, lineWidth: 0.75)
            }
            .shadow(color: theme.shadow, radius: 12, y: 4)
    }
}
