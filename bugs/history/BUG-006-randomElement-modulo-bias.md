# BUG-006: `randomElement()` Uses Time-Based Deterministic Selection with Modulo Bias

**File:** `lib/iterable/iterable_extensions.dart`
**Severity:** 🔴 High
**Category:** Logic Error / Performance / Security
**Status:** Open

---

## Summary

`randomElement()` generates its "random" index using `DateTime.now().microsecondsSinceEpoch % length`. This is:
1. **Not random** — it's deterministic based on execution time; two calls in rapid succession may return the same element.
2. **Biased** — modulo division produces uneven distribution when `length` is not a power of 2.
3. **Incorrect usage** — `dart:math`'s `Random` class exists for this exact purpose and is already used in `common_random.dart` in the same codebase.

---

## Reproduction

```dart
final items = ['a', 'b', 'c'];

// Rapid successive calls likely return the SAME element
// because microseconds haven't changed between calls
for (int i = 0; i < 10; i++) {
  print(items.randomElement()); // May print 'a' 10 times in a row
}
```

```dart
// Modulo bias example with a 3-element list:
// microsecondsSinceEpoch mod 3 distribution:
// If range is [0, N) and N is not divisible by 3,
// values 0,1 appear ceiling(N/3) times, value 2 appears floor(N/3) times
// This means index 0 and 1 are slightly overrepresented vs index 2
```

---

## Root Cause

```dart
// lib/iterable/iterable_extensions.dart ~line 79
T? randomElement() {
  if (isEmpty) return null;
  final int index = DateTime.now().microsecondsSinceEpoch % length;
  //                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  //                TIME-BASED "random" — deterministic, biased
  return elementAt(index);
}
```

---

## Contrast with Existing Pattern

The same codebase already has a proper `Random` implementation in `common_random.dart`:

```dart
// lib/random/common_random.dart — correct approach already used elsewhere
import 'dart:math';
final Random _random = Random();

int randomInt(int min, int max) => min + _random.nextInt(max - min + 1);
```

The `randomElement()` method simply did not use this existing utility.

---

## Impact

1. **Rapid iteration failure**: Code calling `randomElement()` in a tight loop (shuffle, sampling, random display) will get repeated elements because microseconds don't change fast enough.
2. **Statistical bias**: For any list where `length` is not a power of 2, some elements are systematically more likely than others — breaking fair random selection (e.g., randomly picking a winner, shuffling content).
3. **Testability**: Time-based "random" makes unit tests non-deterministic and impossible to seed.

---

## Suggested Fix

```dart
T? randomElement([Random? random]) {
  if (isEmpty) return null;
  final rand = random ?? Random();
  return elementAt(rand.nextInt(length));
}
```

The optional `Random?` parameter allows tests to inject a seeded `Random` for deterministic testing:

```dart
// In tests:
final seeded = Random(42);
expect(['a', 'b', 'c'].randomElement(seeded), equals('c')); // deterministic
```

---

## Related Issue: `randomElement` on List in list_extensions.dart

Check if `list_extensions.dart` has a similar `randomElement` with the same bug — the pattern may be duplicated.

---

## Missing Tests

No test currently verifies statistical distribution or rapid-call behavior:

```dart
group('randomElement', () {
  test('returns null for empty iterable', () {
    expect(<String>[].randomElement(), isNull);
  });

  test('single element always returned for single-element iterable', () {
    expect(['only'].randomElement(), equals('only'));
  });

  test('returns element from the iterable', () {
    final items = ['a', 'b', 'c'];
    final result = items.randomElement();
    expect(items, contains(result));
  });

  test('rapid successive calls return different elements (probabilistic)', () {
    // With time-based selection, this would often fail
    final items = List.generate(100, (i) => i);
    final results = {for (int i = 0; i < 20; i++) items.randomElement()};
    // Should have multiple unique results, not all the same
    expect(results.length, greaterThan(1));
  });

  test('seeded random produces deterministic result', () {
    final items = ['a', 'b', 'c', 'd'];
    final seeded = Random(42);
    final result1 = items.randomElement(seeded);
    final seeded2 = Random(42);
    final result2 = items.randomElement(seeded2);
    expect(result1, equals(result2));
  });
});
```
