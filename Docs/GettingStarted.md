# Getting Started

## 1. Define stable destination identities

Use a small `Hashable` and `Sendable` enum. IDs must remain stable because they key independent navigation paths.

## 2. Define routes

Routes contain lightweight identifiers, not View instances or service objects.

## 3. Own state at the application boundary

Create one `AdaptiveShellState<Tab, Route>` with `@State`. Do not recreate it inside a feature screen.

## 4. Build sections

The first section normally contains two to five compact tabs. Mark sidebar-only collections with `.hidden` compact placement.

## 5. Supply feature content

The content closure receives the selected item and an `AdaptiveShellNavigation` value. Call `push`, `pop`, `popToRoot`, or `select` without exposing the shell state to feature views.

## 6. Map route destinations

Keep route-to-view mapping in the root. This makes deep links, previews, and tests deterministic.

## 7. Add an inspector only when it helps

Use the full initializer and return `true` from `showsInspector` only for destinations with meaningful contextual information.

## 8. Install application dependencies outside the shell

Inject clients, stores, and services above `AdaptiveAppShell`, or explicitly into feature views. The shell should not become a service locator.
