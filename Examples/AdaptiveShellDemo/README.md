# AdaptiveShellDemo

A sample Studio workspace with real session-only local interactions. No account or network connection is required. Each window owns its own store; data and settings reset when that window session ends.

Open `AdaptiveShellDemo.xcodeproj`, select the shared `AdaptiveShellDemo` scheme and run on an iPhone or iPad simulator. The scheme includes model, hosted window and UI tests.

## Walkthrough

1. Open **Spring catalogue** from Overview. The project opens in a detail stack on iPhone and iPad, including when the inspector starts closed.
2. Toggle **Image selection**. Completed tasks change from 2/5 to 3/5, and project progress changes from 40% to 60%. The inspector reads the same tasks and progress, with that project's owners and next unfinished deadline.
3. Return to a root screen and choose **New project**. Empty or whitespace-only names cannot be created. Enter a name/category/date and choose **Create**: the new record appears in Projects and opens immediately. **Cancel** discards the form.
4. Open Search and find that name. Scopes are All, Projects, Tasks and People. Empty or whitespace queries show all available records in the chosen scope; text queries ignore case. People match name/role. `spring` in People shows **No results**. Task results open an editable task qualified by its project ID.
5. In Settings, disable **Show project progress**: cards, detail and inspector hide their percentage/bar. Enable **Keep inspector open**: opening a project presents its inspector in regular width. The toolbar can still hide it; the next project opening presents it again. Disabling the setting closes the inspector. Compact width retains the preference for later regular presentation.
6. Open `adaptiveshell://project/website-qa`. It selects Projects and replaces only its path with one correct destination. Repeat the URL to get the same one-level path. Unknown IDs or malformed links show a message and leave valid history intact. `adaptiveshell://search` selects Search.
7. Change tabs, rotate, or adapt the window. Route arrays, tasks and app-owned search query/scope retain their context. Child form `@State` is not a general restoration contract; persistent storage remains an app integration choice.

## Capture and test arguments

- `--showcase`: cancellable theme/navigation walkthrough.
- `--search`: start on Search.
- `--graphite` / `--stone`: initial theme.
- `--inspector`: start with the regular inspector preference enabled.
- `--profile`: present the sample profile.

The fixture names, people and activity are illustrative. New project IDs are stable UUIDs for the session. [Validation](../../Docs/Validation.md) separates simulator evidence from physical VoiceOver, keyboard, Stage Manager and adoption checks.
