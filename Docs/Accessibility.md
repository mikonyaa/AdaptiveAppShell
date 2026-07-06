# Accessibility

The package and demo are designed around system behavior instead of fixed visual assumptions.

## Included behavior

- System typography and Dynamic Type
- Minimum practical control sizes
- Selected sidebar destinations expose the selected trait
- Symbols are paired with text in navigation
- Progress bars expose labels and percentage values
- Status never depends on color alone
- Reduce Transparency replaces custom glass actions with opaque controls
- Native navigation keeps standard VoiceOver and keyboard behavior

## Verified states

- Standard Dynamic Type on iPhone and iPad
- Accessibility Extra Large on iPhone
- Increase Contrast on iPhone
- Classic, Graphite, and Stone contrast
- Compact tab presentation
- Sidebar with and without inspector

## Consumer checklist

Feature content supplied to the shell still needs its own accessible labels, focus order, empty states, and localization. Test with real translated copy and the largest supported text size before release.
