# BUG-009: `leastOccurrences()` Has Copy-Paste Comment Error

**File:** `lib/iterable/iterable_extensions.dart`
**Severity:** 🟢 Low
**Category:** Documentation
**Status:** Open

---

## Summary

The `leastOccurrences()` method contains a copy-pasted comment from `mostOccurrences()` that says "Find and return the key with the **highest** value" — but `leastOccurrences` should find the **lowest** frequency. This misleads anyone reading the code.

---

## Root Cause

```dart
// lib/iterable/iterable_extensions.dart ~line 59
// Find and return the key with the highest value (frequency) in the map.
//                                  ^^^^^^^
//                                  WRONG: should say "lowest"
final MapEntry<T, int>? leastCommonEntry = frequencyMap.entries.fold(
  null,
  (MapEntry<T, int>? previous, MapEntry<T, int> element) =>
      previous == null || element.value < previous.value ? element : previous,
  //                                   ^
  //                  Note: comparison IS correct (< for least), but comment is wrong
);
```

The logic itself (`element.value < previous.value`) is correct. Only the comment is wrong — it's a copy-paste remnant from `mostOccurrences()`.

---

## Suggested Fix

```dart
// Find and return the key with the lowest value (frequency) in the map.
final MapEntry<T, int>? leastCommonEntry = frequencyMap.entries.fold(
  null,
  (MapEntry<T, int>? previous, MapEntry<T, int> element) =>
      previous == null || element.value < previous.value ? element : previous,
);
```

---

## Related: Undocumented Tie-Breaking Behavior

Both `mostOccurrences()` and `leastOccurrences()` have an additional documentation gap: when multiple elements have the same frequency, which one is returned?

```dart
// Example: ['a', 'a', 'b', 'b'] — both 'a' and 'b' appear twice
// Which does mostOccurrences() return?
final result = ['a', 'a', 'b', 'b'].mostOccurrences();
// ??? Depends on HashMap iteration order (implementation-specific)
```

The fold uses `>` (strict), meaning the **first** encountered maximum is kept (not overwritten on ties). But HashMap insertion/iteration order is not guaranteed in Dart. This behavior should be documented explicitly.

---

## Suggested Documentation Addition

```dart
/// Returns the element that appears the fewest times in this iterable,
/// along with its frequency count.
///
/// When multiple elements share the minimum frequency, returns the first
/// one encountered during iteration. This is implementation-defined for
/// HashMap-backed iterables.
///
/// Returns null if the iterable is empty.
///
/// Example:
/// ```dart
/// ['a', 'a', 'b'].leastOccurrences(); // ('b', 1)
/// ['a', 'b'].leastOccurrences();       // ('a', 1) or ('b', 1) — tie, unspecified
/// ```
```
