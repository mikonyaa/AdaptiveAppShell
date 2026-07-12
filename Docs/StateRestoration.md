# Demo-level state restoration

`AdaptiveAppShell` exposes navigation state; it does not prescribe storage or claim automatic restoration. Keep persistence app-owned so route schemas can evolve with the product.

For a small app whose tab and route enums are `Codable`, save only lightweight values:

```swift
struct ShellSnapshot<Tab: Codable & Hashable, Route: Codable & Hashable>: Codable {
    var selection: Tab
    var paths: [Tab: [Route]]
    var inspectorPresented: Bool
}
```

Restore through the existing API at the application boundary:

```swift
shellState.select(snapshot.selection)
for (tab, path) in snapshot.paths {
    shellState.replacePath(path, in: tab)
}
shellState.isInspectorPresented = snapshot.inspectorPresented
```

Validate decoded tabs and routes against the current app model before applying them. Do not persist `NavigationSplitViewVisibility`; size class and window geometry may differ on the next launch.
