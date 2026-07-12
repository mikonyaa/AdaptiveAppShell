# Architecture

## State ownership

`AdaptiveShellState` is the single mutable navigation source. It stores:

- selected destination
- one route path per destination
- split-view column visibility
- inspector presentation

The state is `@MainActor` and `@Observable`. A root View owns it with `@State`; children navigate through the narrow `AdaptiveShellNavigation` API.

## Compact presentation

Compact width renders a system `TabView`. Every compact item wraps its feature root in its own `NavigationStack`. System navigation and tab chrome receive native Liquid Glass automatically on iOS 26. iOS 17–25 receive an opaque semantic toolbar background. `AdaptiveGlassActionButton` also uses the native glass button style on macOS 26 and falls back on macOS 14–15.

## Regular presentation

Regular width renders a `NavigationSplitView`. Sidebar buttons use the same destination IDs as compact tabs. The currently selected path is attached to the detail column, and an optional inspector reads contextual feature selection.

## Adaptation

Compact and regular presentations never own separate selection or route values. Changing size class swaps presentation while keeping the same state object. If a regular-only collection becomes unavailable in compact width, the shell selects the first valid compact tab and preserves the hidden collection path for later use.

## Why the inspector starts closed

An open inspector can force a portrait iPad to hide its sidebar. Defaulting to closed prioritizes primary navigation. Wide layouts can show it with the toolbar action, and consumers can opt into another initial value.

## Dependency boundary

The package does not define networking, storage, analytics, or feature models. This keeps it reusable and avoids turning navigation into a global application container.

The package also does not claim automatic state restoration. Apps can encode their own route IDs and restore them through the existing selection and path APIs; see `StateRestoration.md`.

## Performance

- Sections and items have stable identity.
- Paths store lightweight `Hashable` routes.
- Demo scrolling uses lazy containers.
- Theme values are immutable and `Sendable`.
- The shell does not erase content into `AnyView`.
