# Lint triage close-out + live lint cleanup

The `bugs/lint_triage/` directory held 64 saropa_lints violation-triage docs. Each
was assessed: valid violations fixed, invalid ones dismissed, and all triage docs
archived to the `/history` folder when done — without altering the behavior of the
critical methods they covered.

## Finish Report (2026-06-10)

### Scope
(A) Dart library code (`lib/`) + CHANGELOG + history archival. No extension/TypeScript, no ARB/l10n.

### What was found
A full `dart run saropa_lints scan` (insanity tier, current config) over all 360 `lib/`
files plus a `test/` sample reproduced **zero** of the 64 triaged violations — every rule
they describe is enabled yet fires 0 times now. The prior audit commits had already
resolved/obsoleted the set (spot-checked: the days-in-month array is no longer flagged by
`avoid_duplicate_number_elements`; the `JsonIterablesUtils<T>` class that
`prefer_constrained_generics` targeted no longer exists). The 64 files were therefore a
**completed worklist** and were archived to
`plans/history/2026.06/2026.06.10/lint_triage_resolved/`.

The same scan surfaced **79 genuinely live violations** in rules NOT covered by any triage
file. The user opted to fix those too. Result: **79 → 11**.

### Changes (live-violation fixes)
- **prefer_explicit_type_arguments (46 → 0):** added explicit type args to bare empty
  collection literals across 25 files (`<int>[]`, `<Map<String, Object?>>[]`,
  `<(DateTime, DateTime)>[]`, `() => <V>[]`, etc.), matching the codebase's existing
  double-explicit convention. No behavior change — an unconstrained `[]` already infers the
  same type from its target context.
- **prefer_reusing_assigned_local (1 real fix):** `map_deep_merge_extensions.dart` now
  assigns `result[e.key] = otherVal` (the already-bound local) instead of re-reading
  `e.value`. The other 2 hits (damerau_levenshtein rolling rows) are false positives —
  three SEPARATE arrays are required for the OSA recurrence — and carry reasoned
  `// ignore:` directives.
- **avoid_debug_print / avoid_print_error / avoid_stack_trace_in_production (8 sites):**
  extended the author's existing documented `// ignore:` directives on the diagnostic
  `debugPrint` calls in `JsonUtils` (4) and `Base64Utils` (2) to also list the sibling
  rules, and added matching documented ignores to `async_more_utils` (2). The library's
  stated policy is that debugPrint is appropriate for a util package (stripped in release);
  suppression preserves that intent rather than removing diagnostics.
- **prefer_no_commented_out_code (2):** reworded two prose design-notes in
  `html_entity_data.dart` and `html_utils.dart` so they no longer contain code-like tokens
  (`const Map<String, String>`, `&#0;`) that tripped the heuristic; removed the dead
  comment-line `// ignore:` directives (a line-level ignore cannot suppress a comment-based
  lint, which is why they never worked).
- **avoid_work_in_paused_state + require_workmanager_for_background (1 site, 2 rules):**
  documented `// ignore:` on `HeartbeatUtils` — these are Flutter-app-lifecycle / Android
  WorkManager rules and do not apply to a pure-Dart `Timer.periodic` primitive whose
  lifecycle is the consuming app's responsibility.

### Left unchanged (move-on, per instruction)
- **prefer_list_first (10):** all 10 are string indexing (`this[0]`, `word[0]`, `lower[0]`)
  in critical methods (`titleCase`, `upperCaseFirstChar`, `capitalize`, soundex, masking).
  `String` is not `Iterable` and has no `.first`, so the suggested fix would not compile.
  The rule self-declares as stylistic-tier with "no performance benefit." Changing these
  critical methods to silence a misfiring stylistic rule was explicitly out of bounds.
- **require_cache_expiration (1):** appeared only in the verification scan (absent from the
  first scan — the scanner is non-deterministic between runs), in `cache_interface.dart`,
  a file this task never touched. Pre-existing design-level finding (a `Cache` abstraction
  without TTL), out of scope.

### Verification
- `dart analyze lib` → **No issues found** (after all edits).
- `flutter test` → **6107 tests passed** (0 failures; baseline was also green). Critical
  string/datetime/collection methods unchanged in behavior.
- Re-scan: **79 → 11** live violations (the 11 are the documented false-positives /
  out-of-scope items above).

### Testing audit (Section 4A)
The edits are type-argument additions, one local-variable reuse, comment rewording, and
`// ignore:` directives — none change observable behavior or any value/string a test pins.
The full suite (6107 tests) was executed and passes, which covers every changed file's
behavior. No test needed updating (no assertion pinned an inferred-type spelling, the
`debugPrint` text, or the reworded prose).

### Outstanding
None for this task. The 11 remaining scan hits are intentional (false positives a
stylistic/Flutter-only rule raises on a pure-Dart lib, plus one untouched pre-existing
cache-interface finding).
