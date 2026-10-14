# Validation matrix

This document describes the 1.0.4 candidate gates. Simulator execution, compile support and physical-device validation are separate evidence. Package tests alone do not establish complete native adaptation or a 10/10 score.

## Reproduction

The source deployment floors remain Swift tools 6.0, iOS 17 and macOS 14. CI pins XcodeGen 2.45.4 and SwiftLint 0.65.0, and keeps Xcode 16.4/macOS 15 and Xcode 26.5/macOS 26 jobs. Local candidate verification uses Xcode 27.0 (27A266a), Swift 6.4 and installed iOS 26.5 simulators: iPhone 17 Pro and iPad Pro 13-inch (M5).

```bash
swift test
swiftlint lint --strict
xcodebuild -project Examples/AdaptiveShellDemo/AdaptiveShellDemo.xcodeproj \
  -scheme AdaptiveShellDemo -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build
xcodebuild -project Examples/AdaptiveShellDemo/AdaptiveShellDemo.xcodeproj \
  -scheme AdaptiveShellDemo -showdestinations

Scripts/run_ui_tests.sh iphone
Scripts/run_ui_tests.sh ipad
```

Each UI script creates an owned simulator from an installed runtime, builds for testing, then executes the actual test products without rebuilding. It retains result bundles under the ignored `DerivedData-qa-*` directory and deletes only its own simulator. These are hosted UI runs, not generic builds.

To reproduce a separate baseline or candidate package consumer:

```bash
python3 Scripts/prepare_consumer.py /tmp/adaptive-baseline --version 1.0.3
swift package --package-path /tmp/adaptive-baseline resolve
swift build --package-path /tmp/adaptive-baseline

python3 Scripts/prepare_consumer.py /tmp/adaptive-candidate
swift package --package-path /tmp/adaptive-candidate resolve
swift build --package-path /tmp/adaptive-candidate
```

Use fresh output directories. Both packages declare tools 6.0, iOS 17/macOS 14 and the public product. The baseline uses the remote URL with exact 1.0.3; the candidate uses an absolute local package path. The consumer defines its own String IDs/routes and never uses `@testable` or imports demo models. Its hosted app is generated from its own `project.yml` and shared scheme.

## Contracts exercised

| Contract | Evidence |
| --- | --- |
| Dynamic configuration | Public consumer controls remove selected/nonselected items, clear/load, reorder, hide and reinsert. Tests assert visible roots/details and preserve independent histories. Duplicate section/item tests verify first-occurrence placement. |
| Adaptation | Hosted public consumer changes compact→regular→compact with both typed paths populated. A separate test-only Studio host forces both subtree replacements in a wide iPad window, asserts actual TabView/split presentation, and checks visible query/scope/results and an existing project destination. Demo rotation/tab checks supplement this; physical resizing remains pending. |
| Project routing | Demo UI opens Overview, Projects and Search projects with inspector preference off/on. Each action reaches the chosen detail; tab return uses that tab's path. |
| Links | Hosted UI checks cold known/unknown/malformed URLs. Model tests check warm/repeated links, one-level replacement and unchanged unrelated paths. Manual warm `simctl openurl` also verifies these outcomes in one running process. |
| Search | Scoped model tests cover empty/whitespace, trimmed case-insensitive project/task/person queries and no match. UI checks `spring`+People, editable task results, named people and retained query/scope. |
| Creation | Model/UI checks reject blank names, cancel without creation, create a stable local ID, and open/find the resulting project. |
| Shared model | Task completion updates progress (40%→60%), inspector tasks, project-specific owners and next unfinished deadline. Both settings have visible UI effects. |
| Snapshot lifecycle | Hosted two-window regression verifies a 160×120 source is captured instead of another key window. Nil window returns nil; cancellation clears the snapshot and stops delayed work. No performance or leak measurement is claimed. |
| Accessibility | UI tests inspect project labels and reach required root/create/task controls at accessibility XXXL. Native VoiceOver and keyboard flows still need physical testing. |
| Reproducibility | Project generation uses XcodeGen 2.45.4; second generation must produce no project diff. Capture owns simulator/record PID and keeps actual screenshots separate from `Design/Mockups`. |

### Local candidate results · 14 October 2026

The baseline is `ed5cc9573a7258cc2549125d538102c9029e753a` (released 1.0.3). A separate exact-version consumer resolved and built successfully; its hosted selected-section removal reproduced the missing remaining destination. The candidate passes that same public boundary scenario.

| Gate | Actual result |
| --- | --- |
| Package tests | 10 passed; exit 0 |
| SwiftLint 0.65.0 | Strict lint: 0 violations; exit 0 |
| Demo, iPhone 17 Pro / iOS 26.5 | 24 passed, 2 iPad-only skips, 0 failed; exit 0 |
| Demo, iPad Pro 13-inch (M5) / iOS 26.5 | 26 passed, 0 skipped, 0 failed; exit 0 |
| Inspector assertions, focused rechecks | Visible/hittable landscape inspector and project routing with explicitly closed inspector both passed after strengthening those tests; exit 0 for each run. |
| Separate public consumer, both devices | 3 passed per device, 0 failed; exit 0 |
| Native warm links | Same running process: known/repeated link reaches Website QA; one Back reaches Projects root. Unknown/malformed links preserve Website QA, and Overview retains its independent Spring catalogue detail. |
| Search regression sensitivity | Reintroducing child-local query/scope reproduces a visible reset from `spring` to `website`; restored app-owned state passes both presentation replacements. |
| Window regression sensitivity | Original capture selects another 1032×1376 key window; the fix captures the requested 160×120 window and passes cancellation checks. |

These native runs used Xcode 27.0. Compatibility/current CI results are recorded with the exact candidate commit in the pull request; local execution does not substitute for those toolchains. Physical iOS 17/macOS 14 checks remain pending.

Five portrait screenshots and the actual showcase GIF were refreshed and visually inspected. The local XCTest landscape attachment has a rotated/cropped framebuffer despite the passing wide-window interaction assertions; it is excluded from current screenshot assets. Its image-capture verification remains pending, separately from the hosted interaction results.

## Physical-device result form

These checks remain pending until actually run. Record device/model, OS, app revision, input/accessibility settings, observed result, pass/fail and a screenshot or recording.

| Check | Steps / expected result | Result |
| --- | --- | --- |
| iPhone / iPad, including minimum OS | Open a different detail in every tab, rotate/resize and return. Route and displayed identity stay aligned. | Pending |
| Stage Manager / multiple windows | Give two windows different projects/search/theme. Resize independently; switching theme captures only its own window. | Pending |
| VoiceOver | Read project name/status/action, activate it, toggle a task, reach sidebar/detail/inspector and recovery alert. | Pending |
| Hardware keyboard | Tab/Shift-Tab and navigation shortcuts reach sidebar, detail, task controls and inspector without losing focus. | Pending |
| Reduce Motion / Transparency / Increase Contrast | Switch themes and inspector; essential controls remain readable and reachable. | Pending device validation |
| Safe areas and accessibility sizes | Check the largest text size in portrait/landscape, split-window widths and inspector on/off. | Pending device validation |
| Independent adoption pilot | Another app team integrates its own model/routes and records API/usability feedback. Prepared consumers do not count as a pilot. | Pending |

## Catalog proposal

After a released revision is available, the external catalog can describe reactive configuration, visible project routing, session-only creation/shared tasks, scoped search and hosted public-consumer validation. It should keep physical gates and adoption pilot pending until supported by evidence. No catalog change is included with this package candidate.
