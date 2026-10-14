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

## Simulator and automated checks

- Standard Dynamic Type on iPhone and iPad
- Accessibility Extra Large on iPhone
- Classic, Graphite, and Stone contrast
- Compact tab presentation
- Sidebar with and without inspector
- Accessibility XXXL project/task/create control reachability
- Project labels, task values and empty/recovery messages in the accessibility hierarchy

These are simulator/UI assertions and visual checks. Physical VoiceOver activation, hardware keyboard focus, Increase Contrast, Reduce Transparency/Motion and Stage Manager are recorded separately in the [validation matrix](Validation.md); system controls do not by themselves prove those device gates.

## Consumer checklist

Feature content supplied to the shell still needs its own accessible labels, focus order, empty states, and localization. Test with real translated copy and the largest supported text size before release.
