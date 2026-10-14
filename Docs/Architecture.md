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

The inspector belongs to the split-view container and its toggle belongs to the detail stack, so pushing a route preserves both panel and control. Inspector eligibility still comes from the consumer's predicate.

## Adaptation

Compact and regular presentations never own separate selection or route values. Changing size class swaps presentation while keeping the same state object. If a regular-only collection becomes unavailable in compact width, the shell selects the first valid compact tab and preserves the hidden collection path for later use.

Configuration changes are observed independently of selection and size class. The first occurrence of each section ID and item ID wins. A valid selection survives reordering; an unavailable selection resolves to the first eligible item. With no eligible items, the shell shows an empty state and retains the current selection and all app-owned paths. The regular detail stack has the selected tab's identity, preventing native stack presentation from leaking between tabs.

Typed paths preserve navigation context. They do not preserve arbitrary child `@State`. The demo therefore owns its `StudioStore` and search query/scope above the adaptive presentation. This follows Apple's [navigation state](https://developer.apple.com/documentation/swiftui/understanding-the-navigation-stack) and [Observation ownership](https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro) guidance.

## Demo boundary

`StudioCoordinator` validates project identity and owns one opening rule for Overview, Projects, Search, creation and URLs. Both presentations push the source tab's typed path. Known project links replace only the Projects path. Parsing and identity validation precede mutations; failures show a message and preserve history.

`StudioStore` owns session-only projects, task completion, progress settings and search context. Progress derives from completed tasks. The list, details, task screen and inspector read the same project. Search builds immutable scoped results once per render, and the empty condition uses those visible results.

Theme transitions capture the view's hosting window through a weak reference. The transition task is cancelled and its snapshot cleared when the root disappears; no connected-scene search is used.

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
