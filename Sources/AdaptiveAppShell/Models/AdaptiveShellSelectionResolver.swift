enum AdaptiveShellSelectionResolver {
    static func resolve<ID: Hashable>(
        current: ID,
        items: [AdaptiveShellItem<ID>],
        isCompact: Bool
    ) -> ID? {
        let candidates = isCompact
            ? items.filter { $0.compactPlacement == .tab }
            : items

        guard let first = candidates.first else { return nil }
        return candidates.contains { $0.id == current } ? current : first.id
    }
}
