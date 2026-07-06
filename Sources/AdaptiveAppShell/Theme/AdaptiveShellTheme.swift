import SwiftUI

public enum AdaptiveShellThemeID: String, CaseIterable, Identifiable, Sendable {
    case classic
    case graphite
    case stone

    public var id: String { rawValue }
}

public struct AdaptiveShellTheme: Identifiable, Sendable {
    public let id: AdaptiveShellThemeID
    public let displayName: String
    public let recommendedColorScheme: ColorScheme
    public let canvas: Color
    public let surface: Color
    public let elevatedSurface: Color
    public let primaryText: Color
    public let secondaryText: Color
    public let separator: Color
    public let accent: Color
    public let sidebarBackground: Color
    public let sidebarPrimaryText: Color
    public let sidebarSecondaryText: Color
    public let sidebarSelectionFill: Color
    public let success: Color
    public let warning: Color
    public let critical: Color
    public let shadow: Color

    public init(
        id: AdaptiveShellThemeID,
        displayName: String,
        recommendedColorScheme: ColorScheme,
        canvas: Color,
        surface: Color,
        elevatedSurface: Color,
        primaryText: Color,
        secondaryText: Color,
        separator: Color,
        accent: Color,
        sidebarBackground: Color,
        sidebarPrimaryText: Color,
        sidebarSecondaryText: Color,
        sidebarSelectionFill: Color,
        success: Color,
        warning: Color,
        critical: Color,
        shadow: Color
    ) {
        self.id = id
        self.displayName = displayName
        self.recommendedColorScheme = recommendedColorScheme
        self.canvas = canvas
        self.surface = surface
        self.elevatedSurface = elevatedSurface
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.separator = separator
        self.accent = accent
        self.sidebarBackground = sidebarBackground
        self.sidebarPrimaryText = sidebarPrimaryText
        self.sidebarSecondaryText = sidebarSecondaryText
        self.sidebarSelectionFill = sidebarSelectionFill
        self.success = success
        self.warning = warning
        self.critical = critical
        self.shadow = shadow
    }

    public static let classic = AdaptiveShellTheme(
        id: .classic,
        displayName: "Classic",
        recommendedColorScheme: .light,
        canvas: Color(red: 0.965, green: 0.957, blue: 0.941),
        surface: Color(red: 0.995, green: 0.992, blue: 0.985),
        elevatedSurface: .white,
        primaryText: Color(red: 0.105, green: 0.11, blue: 0.12),
        secondaryText: Color(red: 0.39, green: 0.40, blue: 0.43),
        separator: Color.black.opacity(0.10),
        accent: Color(red: 0.04, green: 0.39, blue: 0.84),
        sidebarBackground: Color(red: 0.115, green: 0.125, blue: 0.14),
        sidebarPrimaryText: Color.white.opacity(0.96),
        sidebarSecondaryText: Color.white.opacity(0.60),
        sidebarSelectionFill: Color.white.opacity(0.14),
        success: Color(red: 0.22, green: 0.55, blue: 0.27),
        warning: Color(red: 0.92, green: 0.52, blue: 0.06),
        critical: Color(red: 0.78, green: 0.18, blue: 0.17),
        shadow: Color.black.opacity(0.07)
    )

    public static let graphite = AdaptiveShellTheme(
        id: .graphite,
        displayName: "Graphite",
        recommendedColorScheme: .dark,
        canvas: Color(red: 0.085, green: 0.09, blue: 0.10),
        surface: Color(red: 0.125, green: 0.13, blue: 0.145),
        elevatedSurface: Color(red: 0.16, green: 0.165, blue: 0.18),
        primaryText: Color.white.opacity(0.96),
        secondaryText: Color.white.opacity(0.62),
        separator: Color.white.opacity(0.10),
        accent: Color(red: 0.36, green: 0.65, blue: 1.0),
        sidebarBackground: Color(red: 0.065, green: 0.07, blue: 0.08),
        sidebarPrimaryText: Color.white.opacity(0.96),
        sidebarSecondaryText: Color.white.opacity(0.58),
        sidebarSelectionFill: Color.white.opacity(0.13),
        success: Color(red: 0.39, green: 0.76, blue: 0.43),
        warning: Color(red: 1.0, green: 0.66, blue: 0.18),
        critical: Color(red: 1.0, green: 0.38, blue: 0.36),
        shadow: Color.black.opacity(0.28)
    )

    public static let stone = AdaptiveShellTheme(
        id: .stone,
        displayName: "Stone",
        recommendedColorScheme: .light,
        canvas: Color(red: 0.925, green: 0.925, blue: 0.90),
        surface: Color(red: 0.975, green: 0.97, blue: 0.94),
        elevatedSurface: Color(red: 0.995, green: 0.99, blue: 0.965),
        primaryText: Color(red: 0.13, green: 0.15, blue: 0.14),
        secondaryText: Color(red: 0.39, green: 0.42, blue: 0.40),
        separator: Color(red: 0.15, green: 0.19, blue: 0.17).opacity(0.13),
        accent: Color(red: 0.18, green: 0.42, blue: 0.39),
        sidebarBackground: Color(red: 0.20, green: 0.23, blue: 0.22),
        sidebarPrimaryText: Color.white.opacity(0.94),
        sidebarSecondaryText: Color.white.opacity(0.58),
        sidebarSelectionFill: Color.white.opacity(0.14),
        success: Color(red: 0.22, green: 0.50, blue: 0.30),
        warning: Color(red: 0.74, green: 0.46, blue: 0.10),
        critical: Color(red: 0.69, green: 0.22, blue: 0.18),
        shadow: Color.black.opacity(0.08)
    )

    public static func preset(_ id: AdaptiveShellThemeID) -> AdaptiveShellTheme {
        switch id {
        case .classic:
            .classic
        case .graphite:
            .graphite
        case .stone:
            .stone
        }
    }
}
