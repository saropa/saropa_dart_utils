# ENH-004: `Iterable<T>.randomElement({int? seed})` — accept an optional seed

**File (target):** `lib/iterable/iterable_extensions.dart`
**Type:** Enhancement / Missing Option
**Severity:** 🟡 Medium
**Status:** Fixed

---

## Summary

`randomElement()` picks a uniformly-random element but gives the caller no way to
make the choice **deterministic**. The library already ships a seedable RNG
(`CommonRandom` in `lib/random/common_random.dart`), so wiring an optional `seed`
through `randomElement` is a small, self-consistent addition that unblocks
reproducible demo data and stable tests.

---

## Absence Evidence

```bash
grep -nE -A3 "randomElement" ../saropa_dart_utils/lib/iterable/iterable_extensions.dart
# 93:  T? randomElement() {   <-- no parameter
```

## Use Case (consumer's local implementation)

Saropa Contacts re-implements `randomElement` solely to thread a seed through
`CommonRandom` — it would delete its local copy if the library accepted a seed
(`lib/utils/primitive/generate_random/random_list.dart`):

```dart
T? randomItem([int? seed]) {
  if (length < 2) return firstOrNull;
  final Random random = CommonRandom(seed);   // <-- the library's own RNG
  return this[random.nextInt(length)];
}
```

The app uses this for reproducible seeded demo contacts and deterministic widget
tests — both impossible with the current no-arg `randomElement()`.

## Suggested API

```dart
extension IterableExtensions<T> on Iterable<T> {
  /// Returns a random element, or null if empty.
  /// Pass [seed] for a deterministic pick (uses [CommonRandom]).
  T? randomElement({int? seed}) {
    if (isEmpty) return null;
    final list = this is List<T> ? this as List<T> : toList(growable: false);
    return list[CommonRandom(seed).nextInt(list.length)];
  }
}
```

Default (no seed) behavior is unchanged.

## Missing Tests

- Empty → null; single element; same `seed` → identical pick across calls; two
  different seeds → (statistically) different picks; non-List iterable input.

## Environment

- saropa_dart_utils: 1.3.0
- Triggering consumer: Saropa Contacts `random_list.dart`

---

## Finish Report (2026-06-11)

**Scope:** (A) Dart library code — `lib/` + `test/`. No Flutter UI, no l10n, no extension.

**What shipped:** Added an optional `{int? seed}` param to the existing `Iterable<T>.randomElement()` in `GeneralIterableExtensions`. The pick now routes through the library's own `CommonRandom(seed)` instead of a bare `dart:math` `Random()`.

**Implementation notes:**
- Kept the no-allocation `elementAt(...)` approach rather than the bug's `toList()` materialization — `elementAt` + `length` work on any `Iterable`, and only the chosen element is realized.
- Swapped `Random()` → `CommonRandom(seed)`. With no seed, `CommonRandom` seeds from the wall clock, so default randomness is preserved (the bug's "default behavior is unchanged" holds — it stays random each run; the entropy source changes from system to millisecond clock, which is the same as every other seedable RNG path in this library).
- Removed the now-unused `import 'dart:math'` and added `import '.../random/common_random.dart'`.

**Tests (Section 4):**
- Audit: the existing `randomElement` group (10 cases, all no-arg) in `test/iterable/iterable_extensions_test.dart` is unaffected — the new param is optional, so every existing call still compiles and passes.
- Added 4 seed cases: same seed → same element across calls; repeatable across two equal-content lists; empty+seed → null; seeded pick on a non-List (`Set`) iterable.
- Ran `flutter test test/iterable/iterable_extensions_test.dart` → **All 81 tests passed**.
- Ran `dart analyze` → **No issues found** (the transient "CommonRandom undefined" / "unused dart:math" diagnostics were resolved by the import swap).

**Maintenance:** CHANGELOG entry added under the new **1.4.1** section (1.4.0 was deployed mid-task; ENH-001..004 entries were consolidated into 1.4.1 with a proper intro + `[log]` link, and `pubspec.yaml` version bumped 1.4.0 → 1.4.1). CODEBASE_INDEX lists the file already. README verified — no updates needed.

**Dependency note:** `pubspec.yaml` carries the team's `saropa_lints ^13.12.5` bump (13.12.5 exists in the sibling repo but is not yet on pub.dev, so it does not resolve). For local test runs the constraint is temporarily pinned to the published `^13.12.3`; the committed pubspec keeps `^13.12.5`.

**Outstanding:** None for ENH-004.
