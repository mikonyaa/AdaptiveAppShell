import SwiftUI

public enum AdaptiveShellPresentation: Sendable {
    case compact
    case regular
}

private struct AdaptiveShellThemeKey: EnvironmentKey {
    static let defaultValue = AdaptiveShellTheme.classic
}

private struct AdaptiveShellPresentationKey: EnvironmentKey {
    static let defaultValue = AdaptiveShellPresentation.compact
}

public extension EnvironmentValues {
    var adaptiveShellTheme: AdaptiveShellTheme {
        get { self[AdaptiveShellThemeKey.self] }
        set { self[AdaptiveShellThemeKey.self] = newValue }
    }

    var adaptiveShellPresentation: AdaptiveShellPresentation {
        get { self[AdaptiveShellPresentationKey.self] }
        set { self[AdaptiveShellPresentationKey.self] = newValue }
    }
}

public extension View {
    func adaptiveShellTheme(_ theme: AdaptiveShellTheme) -> some View {
        environment(\.adaptiveShellTheme, theme)
    }
}
