# Configuration and migration

The 1.0.4 candidate is a patch to the reusable shell. Public generic types, initializer signatures, deployment floors and navigation methods remain source compatible. There are no runtime dependencies.

## Selection and identity

Supply stable, globally unique item IDs and unique section IDs. If IDs repeat, the first section with that ID and the first item occurrence in accepted sections win. Later duplicates do not create duplicate native tabs or rows; compact placement also comes from the first item.

Every section change is reconciled, including additions, removals, reordering and `.tab`/`.hidden` changes. A still eligible selection remains selected. Otherwise the first eligible item in configuration order becomes selected. Compact candidates use `.tab`; regular candidates include all accepted items.

An empty configuration displays **No destinations** and retains the previous selection. When items return, a valid retained selection is reused; an invalid one falls back to the first eligible item.

## History ownership

Removing or temporarily hiding an item does not delete its path. Reinserting the same ID restores that history. Permanently retired IDs can be cleaned by the application with `state.paths.removeValue(forKey:)`; do this only when its own domain policy permits it.

The regular stack is keyed by tab ID, so a tab switch presents that tab's actual route array. Compact/regular replacement preserves typed routes, not arbitrary child `@State`. Hoist feature state such as queries, drafts or filters above the shell when it must survive replacement.

## Domain validation

The package cannot decide whether an app-owned route ID still exists. Validate restored or URL-derived routes before applying them, and provide an honest unavailable destination when a record disappears. The Studio example demonstrates this without adding storage or URL semantics to the package.

Theme 1.x IDs continue to identify the documented preset family. Application persistence remains optional and app-owned.
