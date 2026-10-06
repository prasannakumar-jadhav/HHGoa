# Bottom navigation and screen scaffolding for VoxPilot

This change layers a three-destination `NavigationBar` onto the existing dashboard by introducing `MainShell` as the new root widget, with `TasksScreen` and `InsightsScreen` as the two new sibling screens. `main.dart` is updated to a minimal wiring file that hands off entirely to `MainShell`. The state-preservation strategy uses `IndexedStack`, and each child screen owns its own nested `Scaffold` with an `AppBar`. All data is static/local — no network calls, no new pub.dev dependencies.

Watch for: **Stale index in Completed tab checkbox handler** (confirmed) — the Completed tab passes `_items.indexOf(completedItems[index])` to `_toggleTask`, which is currently dead code because checkboxes are disabled on that tab. The moment that guard is removed, the index calculation may silently operate on the wrong task.

**Verdict**: APPROVED

---

## High-level view

`MainShell` is a thin coordinator: an `IndexedStack` of three const-constructed screens wrapped in a single outer `Scaffold` that carries only the `NavigationBar`. The outer `Scaffold` has no `AppBar`, so each nested screen owns its own title and actions row — which all three do.

`TasksScreen` stores its task list as mutable state in `_items`, a `List<_TaskItem>` that wraps the existing `Task` model to attach a category string without touching the model file. The `DefaultTabController` / `TabBarView` split into All Tasks and Completed tabs is functional. Checkboxes on the Completed tab are disabled, so the index passed to `_toggleTask` from that tab never fires — but the index calculation there is wrong (see Issues).

`InsightsScreen` is a `StatelessWidget` backed entirely by hardcoded data. It delivers a gradient hero card, a 2×2 `GridView` of stat cards, a `LinearProgressIndicator`-based category breakdown, and a recent-activity `ListTile` sequence — all without any chart library.

No `.withOpacity()` calls appear in any new file; all transparency uses `.withValues(alpha:)`. No new packages were introduced.

---

<details>
<summary>Issues (1)</summary>

1. **Stale index in Completed-tab toggle path** — `_buildTaskCard` receives `_items.indexOf(completedItems[index])` as the index argument when rendering the Completed tab. This is currently safe only because `completedOnly: true` disables the checkbox (`onChanged: null`). If that guard is ever removed, the toggle will operate on whichever position `indexOf` resolves to — correct by object identity today, but fragile if the list is ever rebuilt or replaced. Replace the index parameter with a direct reference to the `_TaskItem` object, or have `_toggleTask` accept the item rather than an integer position.

</details>

<details>
<summary>Details</summary>

### Checkbox toggle and index integrity

`_toggleTask(int index)` mutates `_items[index].task.isDone` directly. `Task.isDone` is declared non-final in `task_model.dart`, so the mutation is valid and `setState` propagates it.

The Completed tab builds `completedItems` as a filtered copy of `_items`, then passes:

```dart
_items.indexOf(completedItems[index])
```

as the index to `_buildTaskCard`. `indexOf` uses object identity, so the resolved index is correct as long as the same `_TaskItem` instance lives in both lists. The risk is forward-looking: the checkbox is unconditionally disabled on the Completed tab, so this code path is never reached at runtime. The fix is to have `_toggleTask` accept the item itself rather than its position, removing the index-arithmetic entirely.

### Dart 3 record syntax in InsightsScreen

The recent-activity list is typed as `List<(String, String)>`, using Dart 3 record syntax. This compiles correctly for any project targeting Dart ≥ 3.0, but if the minimum SDK constraint is ever dropped below that threshold the file will fail to parse. Worth a comment, not a blocker.

</details>

---

<details>
<summary>File map</summary>

| File | What changed |
|---|---|
| `lib/main.dart` | Replaced `DashboardScreen` home with `MainShell`; removed dashboard import |
| `lib/screens/main_shell.dart` | New — `IndexedStack` shell with `NavigationBar`, three destinations |
| `lib/screens/tasks_screen.dart` | New — tabbed task list with checkboxes, category chips, priority badges, FAB |
| `lib/screens/insights_screen.dart` | New — static analytics screen: hero card, 2×2 grid, category bars, activity feed |

Full diff: `git diff main -- lib/main.dart lib/screens/main_shell.dart lib/screens/tasks_screen.dart lib/screens/insights_screen.dart`

</details>
