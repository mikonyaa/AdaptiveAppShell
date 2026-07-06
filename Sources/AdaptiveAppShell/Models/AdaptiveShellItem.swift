import Foundation

public enum AdaptiveShellCompactPlacement: Hashable, Sendable {
    case tab
    case hidden
}

public struct AdaptiveShellItem<ID: Hashable>: Identifiable, Hashable {
    public let id: ID
    public let title: String
    public let systemImage: String
    public let selectedSystemImage: String
    public let compactPlacement: AdaptiveShellCompactPlacement

    public init(
        id: ID,
        title: String,
        systemImage: String,
        selectedSystemImage: String? = nil,
        compactPlacement: AdaptiveShellCompactPlacement = .tab
    ) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
        self.selectedSystemImage = selectedSystemImage ?? systemImage
        self.compactPlacement = compactPlacement
    }
}

extension AdaptiveShellItem: Sendable where ID: Sendable {}

public struct AdaptiveShellSection<ID: Hashable>: Identifiable, Hashable {
    public let id: String
    public let title: String?
    public let items: [AdaptiveShellItem<ID>]

    public init(
        id: String,
        title: String? = nil,
        items: [AdaptiveShellItem<ID>]
    ) {
        self.id = id
        self.title = title
        self.items = items
    }
}

extension AdaptiveShellSection: Sendable where ID: Sendable {}
