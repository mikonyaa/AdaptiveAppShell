# 1.0.4 candidate release notes

Status: review candidate; no 1.0.4 tag or release is implied by this document.

When a selected section disappears, the shell now presents the remaining valid destination without requiring a size-class change. Reordering preserves a valid selection, hidden or removed histories remain app-owned, and regular tab switches present the correct independent detail stack. Duplicate IDs use the first occurrence.

The Studio demo now opens the selected project from Overview, Projects and Search in both presentations. Creating a named project inserts a real session-only record into list/search and opens it. Task changes update shared progress and inspector data. Both workspace settings have visible effects. Scoped search trims the query, ignores case, respects empty-query scopes and displays **No results** when its visible result set is empty.

The inspector includes an accessible close control inside the panel, so it can be dismissed when a narrow native modal presentation covers the main toolbar. Closing does not disable the workspace preference to reopen it for a later project.

Known project links replace one Projects path. Unknown IDs, extra path segments, credentials, queries and fragments produce explicit errors before navigation changes. A missing project is never replaced by the first fixture.

Hosted demo and external-consumer checks supplement package tests. CI retains compatibility/current SDK gates and accepts both plain SemVer and `v`-prefixed tags. Capture creates and cleans its own simulator and recorder. Theme snapshots use the hosting window and cancelled transitions release their image.

The public initializer and typed model remain source compatible: expected package release category **patch**. See [migration rules](Migration-1.0.4.md), [validation evidence](Validation.md) and the [demo walkthrough](../Examples/AdaptiveShellDemo/README.md). Physical-device checks and an independent adoption pilot remain separate release evidence.
