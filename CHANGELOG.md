# Changelog

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
