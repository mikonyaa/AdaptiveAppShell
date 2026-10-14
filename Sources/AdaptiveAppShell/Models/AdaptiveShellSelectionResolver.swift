enum AdaptiveShellSelectionResolver {
    static func uniqueItems<ID: Hashable>(_ items: [AdaptiveShellItem<ID>]) -> [AdaptiveShellItem<ID>] {
        var seen = Set<ID>()
        return items.filter { seen.insert($0.id).inserted }
    }

    static func uniqueSections<ID: Hashable>(
        _ sections: [AdaptiveShellSection<ID>]
    ) -> [AdaptiveShellSection<ID>] {
        var sectionIDs = Set<String>()
        var itemIDs = Set<ID>()
        return sections.compactMap { section in
            guard sectionIDs.insert(section.id).inserted else { return nil }
            let items = section.items.filter { itemIDs.insert($0.id).inserted }
            guard !items.isEmpty else { return nil }
            return AdaptiveShellSection(id: section.id, title: section.title, items: items)
        }
    }

    static func resolve<ID: Hashable>(
        current: ID,
        items: [AdaptiveShellItem<ID>],
        isCompact: Bool
    ) -> ID? {
        let unique = uniqueItems(items)
        let candidates = isCompact
            ? unique.filter { $0.compactPlacement == .tab }
            : unique

        guard let first = candidates.first else { return nil }
        return candidates.contains { $0.id == current } ? current : first.id
    }
}
