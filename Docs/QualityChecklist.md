# Template Quality Checklist

## API

- Stable generic destination IDs
- Independent per-destination route paths
- Empty configuration handled without a crash
- Sidebar-only items normalize safely in compact width
- Inspector is opt-in per destination
- No feature or service dependencies in the package

## Visual

- No gradients
- Glass limited to system chrome and controls
- Opaque content surfaces
- One persistent accent per theme
- Selected state remains obvious without color alone
- iPhone and iPad layouts use platform-appropriate navigation

## Accessibility

- Dynamic Type reflow
- VoiceOver labels and traits
- Status labels include text
- Reduced Transparency fallback
- Increase Contrast verification

## Verification

- `swift test`
- Generic iOS Simulator build
- iPhone simulator launch
- iPad simulator launch
- Classic, Graphite, and Stone screenshots
- Accessibility Extra Large screenshot
- SwiftLint
- No unintended code comments or debug output
