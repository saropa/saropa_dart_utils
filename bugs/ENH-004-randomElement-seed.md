# ENH-004: `Iterable<T>.randomElement({int? seed})` — accept an optional seed

**File (target):** `lib/iterable/iterable_extensions.dart`
**Type:** Enhancement / Missing Option
**Severity:** 🟡 Medium
**Status:** Open

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
