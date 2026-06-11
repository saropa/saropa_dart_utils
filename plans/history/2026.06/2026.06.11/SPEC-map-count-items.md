# SPEC: MapUtils.countItems — for inclusion

**Status:** Already in library (no action needed)
**Proposed location:** lib/map/map_extensions.dart (already present)
**Portability:** Pure Dart. No Flutter, no external packages.

## Purpose — what it does + why it is general-purpose (not proprietary)

`countItems<K, V>(Map<K, Iterable<V>> inputMap)` returns the total number of
elements across every iterable value in the map — it folds the lengths of all
values into a single `int`. Generic over key type `K` and element type `V`, it
works on any `Map<K, List<V>>` / `Map<K, Set<V>>` / `Map<K, Iterable<V>>`.
Typical use: sizing grouped collections such as `Map<Section, List<Item>>`
(e.g. counting selected items across grouped sections). It carries no
contact-domain, Saropa-specific, l10n, icon, or logging dependencies — it is a
plain numeric reduction over a map of iterables.

The Saropa Contacts copy lives in `lib/utils/primitive/map/map_utils.dart` as a
local restore: the comment header notes that the 1.1.x pure-Dart refactor of
saropa_dart_utils had dropped the static `MapUtils` class, so Contacts kept a
local copy of `countItems` and `mapToggleValue`. That gap has since been closed
upstream — see Overlap below.

### Excluded members (not part of this spec)

- **`mapToggleValue<K, V>`** — per the scope note, this is the contact-selector
  mutation pattern (immutable add/remove of a value in a list at a key, four-arg
  shape mirroring the `contact_details_selector` checkbox call sites). It is
  also ALREADY present upstream as `MapExtensions.mapToggleValue` (named-args
  form), so no inclusion proposal is needed for it either.

## Overlap with installed library (saropa_dart_utils 1.4.1)

**The whole util is already in the library — no action needed.**

`lib/map/map_extensions.dart` at lines 216-217 defines, inside
`abstract final class MapExtensions`:

```dart
/// Returns the total number of items across all iterable values in
/// [inputMap].
@useResult
static int countItems<K, V>(Map<K, Iterable<V>> inputMap) =>
    inputMap.values.fold<int>(0, (int sum, Iterable<V> iter) => sum + iter.length);
```

This is byte-for-byte identical to the Contacts implementation (the only
difference is the upstream version carries a `@useResult` annotation and lives
under `MapExtensions` rather than the local `MapUtils`). `mapToggleValue` is
also present upstream (`MapExtensions.mapToggleValue`, named-args form) at the
same file, line 223.

Recommended Contacts follow-up (outside this spec): delete the local
`lib/utils/primitive/map/map_utils.dart` and route the two call patterns to
`MapExtensions.countItems` / `MapExtensions.mapToggleValue`.

## Source (from Saropa Contacts) — verbatim general-purpose member

Debug logging: none present in the source (nothing to strip).

```dart
/// Total number of items across every iterable value in [inputMap].
///
/// Folds the lengths of all values; used to size grouped collections (e.g.
/// counting selected items across a `Map<Section, List<Item>>`).
static int countItems<K, V>(Map<K, Iterable<V>> inputMap) =>
    inputMap.values.fold<int>(0, (int sum, Iterable<V> iter) => sum + iter.length);
```

## Test cases — existing tests (verbatim from Saropa Contacts)

From `test/lib/utils/primitive/map/map_utils_test.dart` (the `countItems`
group only; the `mapToggleValue` group is excluded per scope):

```dart
group('MapUtils.countItems', () {
  test('returns 0 for an empty map', () {
    expect(MapUtils.countItems(<String, List<int>>{}), 0);
  });

  test('sums the lengths of all iterable values', () {
    final Map<String, List<int>> input = <String, List<int>>{
      'a': <int>[1, 2],
      'b': <int>[3],
      'c': <int>[],
    };
    expect(MapUtils.countItems(input), 3);
  });
});
```

## Bulletproofing gaps — concrete edge cases to add for massive coverage

These are not present upstream or in the Contacts tests and would harden the
already-shipped `MapExtensions.countItems`:

- **Empty map** — already covered (`{}` returns `0`); keep.
- **All-empty values** — `{'a': [], 'b': []}` returns `0`.
- **Single key, single element** — `{'a': [1]}` returns `1`.
- **Mixed empty + non-empty** — already covered; add a variant with the empty
  value first vs last to confirm order-independence.
- **`Set` values** — `Map<String, Set<int>>` with a set containing a duplicate
  that collapsed (`{'a': {1, 1}}` is `{1}`) returns `1`, not `2` — confirms it
  counts post-dedup `.length`, not insertion count.
- **Non-`List` `Iterable` values** — a lazy `Iterable` from `Iterable.generate`
  or `map(...)`; confirm `.length` materializes correctly.
- **Large collections / extremes** — a value with `1 << 20` elements, and many
  keys, to confirm the `int` fold does not overflow on 64-bit and matches the
  expected sum.
- **Key type variety** — `int` keys, `enum` keys, and custom-object keys with
  `==`/`hashCode`, to prove `K` genericity is unconstrained.
- **Element type variety** — `Map<String, List<String>>` including Unicode /
  emoji strings (e.g. element `String.fromCharCode(0x1F600)` and
  `'café'`); confirms element CONTENT is irrelevant — only `.length`
  matters — so multi-code-unit emoji and combining marks each count as exactly
  one element.
- **Nullable element type** — `Map<String, List<int?>>` with `null` elements
  (`{'a': [null, 1, null]}` returns `3`); nulls still count toward length.
- **Single huge value vs many small values** — `{'a': [...100 items]}` equals
  `{for 100 keys: [1 item]}` (both `100`) — fold associativity sanity check.
- **Immutability** — assert `countItems` does not mutate `inputMap` or any of
  its iterable values (compare a deep snapshot before/after).
```
