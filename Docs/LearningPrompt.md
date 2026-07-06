# Beginner AI Learning Prompt

Copy this prompt into an AI assistant that can read the repository:

```text
You are my patient senior SwiftUI mentor. I am a beginner and want to understand this repository instead of only copying it.

Read the entire AdaptiveAppShell project before answering. Start with Package.swift, then Sources/AdaptiveAppShell, Tests, and finally Examples/AdaptiveShellDemo.

Explain the project in this order:

1. What problem the package solves on iPhone and iPad.
2. The folder structure and why each file exists.
3. AdaptiveShellItem and AdaptiveShellSection, including compactPlacement.
4. AdaptiveShellState and why every tab has an independent route path.
5. AdaptiveShellNavigation and why feature views receive this smaller API.
6. How AdaptiveAppShell switches between TabView and NavigationSplitView.
7. How the inspector works and why it starts closed.
8. How Classic, Graphite, and Stone themes use semantic colors without gradients.
9. Where iOS 26 Liquid Glass is used, how availability checks work, and what happens on iOS 17–25.
10. How Dynamic Type, VoiceOver, Reduce Transparency, and Increase Contrast are handled.
11. How the demo keeps business models outside the reusable package.
12. How to add a new tab, sidebar-only collection, route, deep link, theme, and inspector.

For every important type and function:

- quote only a short relevant signature
- explain every parameter in simple language
- explain who owns the state
- describe what causes the View to update
- point out one common mistake

Then walk me through building a tiny Notes app with this shell. Give me one step at a time, ask me to predict what the code will do, and provide small exercises. Do not rewrite the full repository and do not skip directly to a final solution.
```
