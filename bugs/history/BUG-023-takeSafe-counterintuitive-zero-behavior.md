# BUG-023: `takeSafe()` Returns Original List for `count=0`, Violating Principle of Least Surprise

**File:** `lib/list/list_extensions.dart`
**Severity:** 🟡 Medium
**Category:** API Design / Unexpected Behavior
**Status:** Open

---

## Summary

`takeSafe(0)` returns the original list instead of an empty list. This contradicts the behavior of Dart's built-in `take(0)` which returns an empty iterable — and will surprise any developer familiar with standard Dart semantics.

---

## Reproduction

```dart
final list = [1, 2, 3, 4, 5];

// Dart built-in behavior
list.take(0).toList(); // [] — empty list

// saropa_dart_utils behavior
list.takeSafe(0); // [1, 2, 3, 4, 5] — original list returned!
list.takeSafe(-1); // [1, 2, 3, 4, 5] — original list returned!
list.takeSafe(null); // [1, 2, 3, 4, 5] — original list returned!
```

---

## Root Cause

```dart
// lib/list/list_extensions.dart ~line 258
List<T> takeSafe(int? count, {bool ignoreZeroOrLess = true}) {
  if (isEmpty || count == null || (ignoreZeroOrLess && count <= 0)) {
    return this;                  // ← Returns original list for count=0
  }
  if (count >= length) return this;
  return take(count).toList();
}
```

The parameter `ignoreZeroOrLess = true` means "treat count <= 0 as 'no change'" — but this is not what "take 0 items" means.

---

## When This Causes Bugs

```dart
// Code trying to show "top 0 results" (empty state)
final topResults = results.takeSafe(userLimit);

// If userLimit = 0 (user configured no results), they expect empty list
// But get the full list instead!

// Pagination with page size of 0 (edge case)
final page = items.takeSafe(pageSize); // pageSize=0 → returns all items!
```

---

## The Parameter Name is Also Problematic

`ignoreZeroOrLess` is a confusing name for this behavior. "Ignore" could mean:
- "If count is 0 or less, ignore the count and return original" (current behavior)
- "If count is 0 or less, ignore the error and return empty list" (more expected)

---

## Suggested Fix

### Option A: Change default to `ignoreZeroOrLess: false` (breaking change)
```dart
List<T> takeSafe(int? count, {bool ignoreZeroOrLess = false}) {
  if (count == null) return this; // null means "no limit"
  if (ignoreZeroOrLess && count <= 0) return this;
  if (count <= 0) return <T>[]; // default: 0 means empty
  if (count >= length) return this;
  return take(count).toList();
}
```

### Option B: Rename and clarify semantics (cleaner)
```dart
/// Takes up to [count] items from this list.
///
/// If [count] is null, returns this list.
/// If [count] is 0 or negative, returns an empty list (matches Dart's take() semantics).
/// If [count] >= length, returns this list.
List<T> takeSafe(int? count) {
  if (count == null || count >= length) return this;
  if (count <= 0) return <T>[]; // Standard Dart: take(0) = []
  return take(count).toList();
}
```

---

## Missing Tests

The current tests *document* the current behavior but don't challenge it:

```dart
// From test/list/list_extensions_test.dart ~line 439
test('count is 0 returns original list (ignoreZeroOrLess=true)', () {
  expect([1, 2, 3].takeSafe(0), equals([1, 2, 3]));
});
```

Tests that should be added to expose the inconsistency:

```dart
group('takeSafe vs Dart take() semantics', () {
  test('take(0) returns empty list (Dart builtin)', () {
    expect([1, 2, 3].take(0).toList(), isEmpty);
  });

  test('takeSafe(0) should also return empty list for consistency', () {
    // Currently fails with current implementation:
    expect([1, 2, 3].takeSafe(0), isEmpty);
  });

  test('takeSafe with ignoreZeroOrLess:false returns empty for 0', () {
    expect([1, 2, 3].takeSafe(0, ignoreZeroOrLess: false), isEmpty);
  });

  test('takeSafe null returns original', () {
    expect([1, 2, 3].takeSafe(null), equals([1, 2, 3]));
  });
});
```
