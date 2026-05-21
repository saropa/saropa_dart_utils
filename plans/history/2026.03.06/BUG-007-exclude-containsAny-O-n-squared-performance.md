# BUG-007: `exclude()` and `containsAny()` Have O(n²) Performance

**File:** `lib/list/list_extensions.dart`
**Severity:** 🔴 High
**Category:** Performance
**Status:** Open

---

## Summary

Both `exclude()` and `containsAny()` use `List.contains()` inside a loop, creating O(n×m) time complexity. For large lists this degrades to O(n²). Converting the comparison list to a `Set` reduces lookup to O(1), making the overall complexity O(n).

---

## Affected Methods

### `exclude()`

```dart
// lib/list/list_extensions.dart ~line 298
List<T> exclude(List<T> items) {
  if (isEmpty) return this;
  if (items.isEmpty) return this;
  return where((T e) => !items.contains(e)).toList();
  //                    ^^^^^^^^^^^^^^^^^^^^^^^^
  //                    O(m) lookup inside O(n) where → O(n×m) total
}
```

### `containsAny()`

```dart
// lib/list/list_extensions.dart ~line 338
bool containsAny(List<T>? inThis) {
  if (isEmpty) return false;
  if (inThis == null || inThis.isEmpty) return false;
  for (final T find in this) {
    if (inThis.contains(find)) {  // O(m) inside O(n) loop → O(n×m)
      return true;
    }
  }
  return false;
}
```

---

## Performance Benchmark

For two lists of 10,000 elements:
- Current: ~100,000,000 comparisons (O(n²))
- Fixed: ~20,000 operations (O(n) for Set construction + O(n) for iteration)
- **Speedup: ~5,000x**

```
n=100:     100×100 = 10,000 ops     vs  300 ops
n=1,000:   1K×1K  = 1M ops          vs  2,000 ops
n=10,000:  10K×10K = 100M ops       vs  20,000 ops  ← meaningful production scenario
```

---

## Suggested Fix

### `exclude()`
```dart
List<T> exclude(List<T> items) {
  if (isEmpty) return this;
  if (items.isEmpty) return this;
  final Set<T> excluded = items.toSet(); // O(m) — one-time cost
  return where((T e) => !excluded.contains(e)).toList(); // O(1) lookup
}
```

### `containsAny()`
```dart
bool containsAny(List<T>? inThis) {
  if (isEmpty) return false;
  if (inThis == null || inThis.isEmpty) return false;
  final Set<T> searchSet = inThis.toSet(); // O(m) — one-time cost
  return any(searchSet.contains);          // O(n) with O(1) lookups
}
```

---

## Caveat: Custom Equality

If the list contains objects with custom `==`/`hashCode`, the `Set` approach works correctly because `Set` uses `==` and `hashCode` for membership testing — the same operators `List.contains` uses.

If objects use identity comparison by default (no custom `==`), both approaches are equivalent — but `Set` is still faster.

---

## Impact on Real Usage

These methods are used for filtering and intersection operations — common in:
- Filtering contact lists
- Deduplication operations
- UI filtering (search, tags, categories)

With UI lists of even 500+ items, the difference becomes perceptible.

---

## Also: Typo in `containsAny` Comment

```dart
// lib/list/list_extensions.dart ~line 349
if (inThis.contains(find)) {
  // fund  ← TYPO: should be "found"
  return true;
}
```

---

## Missing Tests

No performance regression tests exist:

```dart
group('exclude performance', () {
  test('handles large lists efficiently', () {
    final large = List.generate(10000, (i) => i);
    final toExclude = List.generate(5000, (i) => i * 2); // even numbers

    final stopwatch = Stopwatch()..start();
    final result = large.exclude(toExclude);
    stopwatch.stop();

    expect(result.length, equals(5000)); // odd numbers remain
    // Should complete in well under 1 second
    expect(stopwatch.elapsedMilliseconds, lessThan(500));
  });
});

group('containsAny performance', () {
  test('handles large lists efficiently', () {
    final list1 = List.generate(10000, (i) => i);
    final list2 = List.generate(10000, (i) => i + 5000); // overlap at 5000-9999

    final stopwatch = Stopwatch()..start();
    final result = list1.containsAny(list2);
    stopwatch.stop();

    expect(result, isTrue);
    expect(stopwatch.elapsedMilliseconds, lessThan(200));
  });
});
```
