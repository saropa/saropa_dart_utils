# Suppress prefer_correct_callback_field_name in BacktrackingSolver

The `BacktrackingSolver` class exposes four function-typed public fields —
`choices` (candidate generator), `apply` (state transform), `isComplete` and
`isValid` (predicates) — that together define a depth-first backtracking search.
The saropa_lints stylistic-tier rule `prefer_correct_callback_field_name`, which
the project enables in `analysis_options.yaml`, flagged all four under the
analysis-server plugin, asking that callback fields adopt the `onXxx` Flutter
convention. The rule does not surface through the `dart analyze` / `flutter
analyze` CLI (which omits the plugin), only in the IDE.

## Finish Report (2026-06-12)

### Scope
- (A) Dart: `lib/collections/backtracking_utils.dart` — added a file-level
  `// ignore_for_file: prefer_correct_callback_field_name` with a documented
  rationale. No behavior, signature, or public-API change.
- (C) Docs: `CHANGELOG.md` — one entry appended to the Unreleased "Changed"
  section, matching the three prior documented saropa_lints suppressions there.

### Why suppress rather than rename
The four fields are pure strategy callbacks passed to the constructor, not UI
event handlers. The `onXxx` naming convention the rule enforces signals "this is
an event hook"; applying it here (`onChoices`, `onApply`) would misdescribe a
candidate generator and a state transform. The fields are also public members of
a published package (`saropa_dart_utils` on pub.dev), so renaming them is a
breaking API change for every consumer. Suppression with a reason is the correct
resolution for a stylistic false positive on a published surface.

### Why file-level rather than per-field `// ignore:`
Each field carries a `///` dartdoc comment immediately above its declaration. A
`// ignore:` line must sit on the line directly above the diagnostic target;
inserting one between the dartdoc and the field declaration would detach the
dartdoc (Dart only attaches `///` that is immediately adjacent to the
declaration), silently dropping the documentation. A single
`// ignore_for_file` placed after the `library;` directive avoids that and
covers all four sites with one rationale block.

### Verification
- `flutter test test/collections/backtracking_utils_test.dart` — all 8 tests
  pass (N-Queens counts, subset-sum, invalid-root null case). The constructor's
  named arguments are the field names; their being unchanged confirms the public
  API is intact.
- `flutter analyze lib/collections/backtracking_utils.dart` — clean (the rule is
  plugin-only and does not run in the CLI; the suppression is for the IDE
  analysis-server view).

### Files changed
- `lib/collections/backtracking_utils.dart` — suppression comment + directive.
- `CHANGELOG.md` — Unreleased "Changed" entry.
- `plans/history/2026.06/2026.06.12/suppress-callback-field-name-backtracking.md`
  — this report.

### Outstanding
None. The fenwick_tree_utils.dart line that was open in the editor carried no
diagnostic and was not modified.
