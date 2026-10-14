# Template Quality Checklist

## API

- Stable generic destination IDs
- Independent per-destination route paths
- Empty configuration handled without a crash
- Dynamic section reconciliation and deterministic duplicate handling
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
- Hosted demo model, window lifecycle and UI tests
- Separate public-API consumer, released baseline and local candidate
- Plain SemVer and v-prefixed CI triggers
- Two-SDK CI and second-generation XcodeGen equality
- Owned simulator / recorder cleanup in capture and test scripts
- No unintended code comments or debug output

See [Validation](Validation.md) for concrete contracts and remaining physical-device/adoption gates.
