# SPEC: BoolSortingHelper.compareTo — for inclusion

**Status:** Proposed (from Saropa Contacts)
**Proposed location:** lib/bool/bool_sort_extensions.dart
**Portability:** Pure Dart. No Flutter, no external packages. (`meta` is already used across the library's other bool extensions for `@useResult` and would be applied here too.)

## Purpose — what it does + why it is general-purpose (not proprietary)

`bool` does not implement `Comparable<bool>` in the Dart core library, so `[true, false].sort()` throws and there is no canonical way to order booleans. `BoolSortingHelper` adds a `compareTo(bool other)` extension method on `bool` that mirrors the `Comparable.compareTo` contract:

- returns `0` when both values are equal (both `true` or both `false`),
- returns `-1` when `this` is `true` and `other` is `false` (true sorts FIRST),
- returns `1` when `this` is `false` and `other` is `true` (false sorts LAST).

This makes booleans usable as a sort key — e.g. `items.sort((a, b) => a.isPinned.compareTo(b.isPinned))` to float the `true` rows to the top, or as a tie-break comparator combined with other keys. The ordering convention (true before false) is the common "flagged items first" expectation.

Nothing here is app-specific: no contact-domain logic, no Saropa formats, no icons, no l10n, no search syntax. It is a generic, language-level gap-filler.

### Overlap check (D:/tools/Pub/Cache/hosted/pub.dev/saropa_dart_utils-1.4.1/lib)

The library already has a `bool/` category with:

- `bool_iterable_extensions.dart` — `BoolIterableExtensions` on `Iterable<bool>` (`mostOccurrences`, `leastOccurrences`, `anyTrue`, `anyFalse`, `countTrue`, `countFalse`, `reverse`).
- `bool_string_extensions.dart` — `String`/`String?` → `bool` conversions.

Neither defines a `compareTo` on a single `bool`, and no `BoolSortingHelper`-equivalent exists anywhere in the library (the other `compareTo` hits across `lib/` are unrelated comparators on strings, intervals, versions, etc.). **Net-new** — drop it alongside the existing bool extensions in `lib/bool/`.

## Source (from Saropa Contacts) — verbatim general-purpose member (debug logging stripped)

Excluded from the quoted source:

- `import 'package:saropa/utils/_dev/debug.dart';` — app-internal debug import (removed).
- The `try`/`on Object catch (error, stack) { debugException(error, stack); return 0; }` wrapper — app Crashlytics/`debugException` reporting. The body is total branch coverage over a closed 2-value domain and cannot throw, so the catch is dead defensiveness; it is stripped for the library version. If the library prefers a non-throwing guarantee, keep the bare body (below) — it has no failure path.

```dart
extension BoolSortingHelper on bool {
  /// Compares this boolean to [other], following the [Comparable.compareTo]
  /// contract so booleans can be used as a sort key.
  ///
  /// `bool` does not implement [Comparable] in dart:core, so this fills that
  /// gap. Ordering convention: `true` sorts BEFORE `false` ("flagged first").
  ///
  /// Returns:
  /// - `0` when both values are equal,
  /// - `-1` when this is `true` and [other] is `false`,
  /// - `1` when this is `false` and [other] is `true`.
  ///
  /// ref: https://stackoverflow.com/questions/61881850/sort-list-based-on-boolean
  // ignore: avoid_positional_boolean_parameters -- a bool comparator must take
  // a positional bool to match the Comparable.compareTo signature.
  int compareTo(bool other) {
    // Equal values (both true or both false) compare as 0.
    if (this == other) {
      return 0;
    }

    // this == true, other == false -> this sorts first.
    if (this && !other) {
      return -1;
    }

    // this == false, other == true -> this sorts last.
    // (Unreachable fall-through retained for total-branch clarity.)
    return 1;
  }
}
```

## Test cases — existing tests verbatim (from `test/lib/utils/primative/primative_utils_test.dart`)

```dart
group('Sort Utils', () {
  group('compareTo', () {
    test('when both booleans are true', () {
      expect(true.compareTo(true), equals(0));
    });

    test('when this is true and other is false', () {
      expect(true.compareTo(false), equals(-1));
    });

    test('when this is false and other is true', () {
      expect(false.compareTo(true), equals(1));
    });

    test('when both booleans are false', () {
      expect(false.compareTo(false), equals(0));
    });
  });
});
```

(The sibling `compareToStringNullable` group in the same file is a different symbol — a `String`-comparison util — and is out of scope for this bool spec.)

## Bulletproofing gaps — concrete edge cases to add for massive coverage

The domain is closed (two inputs x two = four combinations, all already covered above), so "bulletproofing" here means proving the comparator's CONTRACT and its real sorting BEHAVIOR rather than chasing unicode/NaN/infinity-style inputs that do not apply to `bool`.

- **Antisymmetry:** for every pair `(a, b)`, assert `a.compareTo(b)` is the exact negation of `b.compareTo(a)` (`true.compareTo(false) == -false.compareTo(true)`, and `== 0` for equal pairs).
- **Reflexivity:** `true.compareTo(true)` and `false.compareTo(false)` both `0` (covered; keep as the identity-law statement).
- **Sign-only contract (not magnitude):** assert `result.sign` rather than exact `-1`/`1`, so the util stays valid if it ever returns `-2`/`2`. Add `expect(true.compareTo(false), isNegative)` / `expect(false.compareTo(true), isPositive)` / `expect(true.compareTo(true), isZero)`.
- **Real `List.sort` integration:** `(<bool>[false, true, false, true]..sort((a, b) => a.compareTo(b)))` equals `[true, true, false, false]` — proves the "true first" convention through the actual sort engine, the primary use case.
- **Reverse-order sort:** sorting with `(a, b) => b.compareTo(a)` yields `[false, false, true, true]` — confirms the comparator composes for descending order.
- **Stability under sort:** sort a list of records `(bool flag, int idx)` by `flag` only and assert original index order is preserved within each group (Dart's `List.sort` is not guaranteed stable, so document the expectation or use `iterable_stable_sort_extensions` from this library; at minimum assert the bucket partition is correct).
- **Single-element and empty lists:** `<bool>[].sort(...)` and `[true].sort(...)` do not throw and leave the list unchanged (boundary/no-op).
- **All-same lists:** `[true, true, true]` and `[false, false, false]` sort to themselves (no spurious reordering when every `compareTo` returns 0).
- **Transitivity sanity:** with only two values transitivity is trivial, but assert the partition holds across a large list (e.g. 10_000 alternating booleans sort into a clean `true`-block then `false`-block) to catch any future off-by-one in the branch logic.
- **Nullable note (out of scope, document only):** the extension is on non-nullable `bool`; calling on a `bool?` is a compile error. If a `bool?` comparator is wanted later, that is a separate `BoolNullableSortExtensions.compareToNullable(bool?)` proposal (decide null-first vs null-last), NOT a change to this method.

Not applicable to this util (closed boolean domain): unicode/emoji, zero/negative/infinity/NaN numerics, leap years, DST, locale.
