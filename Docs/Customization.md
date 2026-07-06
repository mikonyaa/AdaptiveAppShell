# Customization

## Navigation items

`AdaptiveShellItem` controls title, regular and selected symbols, and compact placement. Keep compact navigation between two and five destinations.

## Sidebar sections

Group secondary destinations in `AdaptiveShellSection`. A nil section title creates an unlabelled primary group.

## Themes

Built-in presets:

- `AdaptiveShellTheme.classic`
- `AdaptiveShellTheme.graphite`
- `AdaptiveShellTheme.stone`

All colors are semantic: canvas, surface, text, separator, accent, sidebar, and statuses. Build a custom theme through the public initializer instead of inserting raw colors throughout feature views.

## Content surfaces

`AdaptiveShellCard` provides the package surface style. It is intentionally opaque. Do not turn every card into glass; blur reduces hierarchy and can make text depend on unpredictable background content.

## Liquid Glass actions

`AdaptiveGlassActionButton` uses the native glass button style on iOS 26 and macOS 26. With Reduce Transparency or on earlier systems, it falls back to a bordered semantic control.

## Inspector

Keep inspector content short and contextual. Do not duplicate an entire detail screen. Good inspector content includes metadata, current selection, quick status, or a compact checklist.

## Deep links

Parse URLs once at the application boundary, then select the destination and replace or append its path through `AdaptiveShellState`.
