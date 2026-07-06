# Adaptive App Shell — Design Brief

## Product purpose

Adaptive App Shell is the reusable structural layer developers usually rebuild at the start of every SwiftUI product. It owns navigation shape, selection, presentation, and platform adaptation without imposing a business domain or networking architecture.

The example product is a small studio workspace. It uses believable projects, deadlines, recent activity, and people so the shell can be judged in a realistic interface rather than an abstract component gallery.

## Navigation model

The primary destinations are Overview, Projects, Activity, Search, and Settings.

On compact iPhone layouts:

- Primary destinations use the system bottom tab bar.
- Each tab keeps an independent `NavigationStack` and history.
- Search is directly reachable and becomes a dedicated search experience.
- Secondary actions stay in the navigation toolbar.
- Detail screens push naturally instead of opening desktop-like panels.

On regular iPad layouts:

- Primary destinations move into a collapsible sidebar.
- Project collections are grouped below the primary navigation.
- Content uses the center column.
- A contextual inspector appears only when the selected content benefits from it.
- The interface remains useful when the sidebar or inspector is hidden.

The shell should also behave correctly in iPad multitasking, compact split-screen widths, landscape iPhone layouts, and large accessibility text sizes.

## Visual direction

The design is intentionally quiet and editorial rather than futuristic.

- Warm off-white is the default canvas in light appearance.
- Graphite is used for dark appearance and high-contrast navigation surfaces.
- System blue is the only persistent accent.
- Status colors appear only when they communicate real state.
- No decorative mesh gradients, glowing blobs, or ornamental glass cards.
- Cards use subtle tonal separation and thin borders instead of heavy shadows.
- System typography and SF Symbols provide a familiar hierarchy.
- Spacing follows a consistent 4-point base rhythm, with 16–24 points around major groups.

Liquid Glass belongs to navigation, toolbars, search, menus, and transient controls. Regular content stays opaque and readable. Interactive glass is reserved for elements that respond to touch or pointer input.

## Example content

The overview shows a concise morning summary, three active projects, a small upcoming section, and recent team activity. Example project names use ordinary studio language such as “Spring catalogue”, “Website QA”, and “Packaging review”. The interface avoids meaningless analytics and decorative charts.

## Interaction principles

- Selection always has one clear visual treatment.
- Changing size class preserves the selected destination and navigation history.
- Re-selecting an active root destination returns to its root or scrolls to the beginning.
- Sheets are enum-driven and mutually exclusive.
- Search keeps its query when moving between compatible layouts.
- Sidebar disclosure, inspector visibility, and column width changes animate with restrained system motion.
- Reduced Motion replaces spatial transitions with short opacity changes.
- Reduced Transparency replaces glass with high-contrast opaque materials.

## Accessibility targets

- No critical meaning depends on color alone.
- Interactive targets remain at least 44 by 44 points.
- Dynamic Type can reflow cards without clipping essential text.
- VoiceOver order follows the visual hierarchy.
- Sidebar sections, badges, selected destinations, and project status expose useful labels and traits.
- Keyboard focus and common commands are supported on iPad.

## Architecture target

- `AppTab` is the stable source of destination identity and metadata.
- Every tab owns an independent route path.
- Compact and regular presentations share navigation state rather than duplicating it.
- Global dependencies are installed once at the shell boundary.
- Feature data remains explicitly injected and does not leak into the shell.
- Route, sheet, and deep-link destinations use lightweight enum values.
- iOS 26 visual APIs are availability-gated with practical iOS 17–25 fallbacks.

## Mockup acceptance criteria

The mockups must demonstrate:

1. The same Overview destination on iPhone and iPad.
2. Bottom-tab navigation in compact width.
3. Sidebar, center content, and contextual inspector in regular width.
4. A realistic detail or search state that proves the shell supports more than a dashboard.
5. Restrained Liquid Glass that does not reduce contrast or dominate the content.

## Implementation sequence after approval

1. Build the shared tab, route, sheet, and navigation-state models.
2. Implement compact and regular shell presentations.
3. Add the studio demo content and preview fixtures.
4. Add deep links, state restoration, keyboard commands, and accessibility behavior.
5. Validate iPhone, iPad, multitasking, Dynamic Type, reduced effects, and earlier-system fallbacks.
6. Record the final GIF and write integration and learning documentation.
