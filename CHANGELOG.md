# Changelog

## Unreleased · 1.0.4 candidate

- Reconcile dynamic sections and compact placement, with deterministic first-occurrence duplicate handling and retained app-owned histories.
- Give each regular detail stack its tab identity to preserve the correct visible destination when switching tabs.
- Open Studio projects consistently from Overview, Projects, Search, creation and validated links, regardless of inspector visibility.
- Add session-only creation, shared task/progress data, effective settings and scoped search with retained query/scope.
- Reject unknown and malformed links explicitly, without fixture fallback or navigation mutations.
- Capture theme transitions from their hosting window and cancel pending transition work on disappearance.
- Add hosted demo tests and a separate public consumer; align version-tag triggers, pinned tools and owned-simulator capture.

No public initializer or typed navigation model changes. See [candidate notes](Docs/ReleaseNotes-1.0.4.md) and [migration rules](Docs/Migration-1.0.4.md).

## 1.0.3

- Added coverage for invalid selection, compact/regular transitions, deep-link path replacement, inspector state, and per-tab navigation.
- Applied the native glass button style consistently on iOS 26 and macOS 26 with earlier-system and Reduce Transparency fallbacks.
- Clarified that theme IDs represent built-in preset families in `1.x`.
- Replaced the broad restoration claim with an app-owned recipe using the existing state API.
- Aligned the package and demo version metadata with `1.0.3`.

## 1.0.2

- Recompressed the showcase GIF at the same 400×870 size and 20 fps while reducing preview weight

## 1.0.1

- Re-recorded the showcase at 20 fps with balanced time for every theme
- Added a warm-launch capture path that removes launch frames from the GIF
- Made the loop return to the same Classic overview state for a clean repeat

## 1.0.0

- Added compact tab and regular sidebar presentations
- Added independent route paths per destination
- Added optional contextual inspector
- Added sidebar-only destinations
- Added Classic, Graphite, and Stone themes
- Added an accessible crossfade when switching between light and dark themes
- Added iOS 26 Liquid Glass controls and earlier-system fallbacks
- Added demo app, tests, screenshots, GIF capture, and documentation
