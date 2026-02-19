# BUG-010: `toMapStringDynamic()` Silently Loses Data on Key Collisions

**File:** `lib/map/map_extensions.dart`
**Severity:** 🔴 High
**Category:** Data Loss / Logic Error
**Status:** Open

---

## Summary

When `toMapStringDynamic()` is called with `ensureUniqueKey: false` (the non-default path), duplicate string keys silently overwrite each other. If a `Map<dynamic, dynamic>` has keys `1` (int) and `'1'` (string), both stringify to `'1'` — one value is permanently lost with no warning.

Even with `ensureUniqueKey: true`, the behavior is silent (no exception, no log) — the second key is simply dropped.

---

## Reproduction

```dart
// A dynamic map with both int key 1 and String key '1'
final dynamic json = {1: 'int-one', '1': 'string-one', 2: 'two'};

// With ensureUniqueKey: false (default Dart map behavior)
final result = MapExtensions.toMapStringDynamic(json, ensureUniqueKey: false);
print(result); // {'1': 'string-one', '2': 'two'} — 'int-one' is SILENTLY LOST

// With ensureUniqueKey: true
final result2 = MapExtensions.toMapStringDynamic(json, ensureUniqueKey: true);
print(result2); // {'1': 'int-one', '2': 'two'} — 'string-one' is SILENTLY DROPPED
```

---

## Root Cause

```dart
// lib/map/map_extensions.dart ~line 214
if (json is Map<dynamic, dynamic>) {
  if (ensureUniqueKey) {
    final Map<String, dynamic> result = <String, dynamic>{};
    json.forEach((dynamic key, dynamic value) {
      result.putIfAbsent(key.toString(), () => value);
      // Silently skips duplicate string keys — no warning
    });
    return result;
  }
  return json.map(
    (dynamic key, dynamic value) =>
        MapEntry<String, dynamic>(key.toString(), value),
  );
  // Dart's Map.map() silently overwrites duplicate keys (last wins)
}
```

---

## Impact

- JSON data from APIs may have both numeric and string versions of the same key (unusual but possible in dynamic/typed languages like JavaScript).
- Silently dropping data is far worse than throwing — callers have no way to detect or recover from the data loss.
- The `ensureUniqueKey` parameter name suggests it prevents issues, but it doesn't warn — it just picks first instead of last.

---

## Suggested Fix

```dart
static Map<String, dynamic>? toMapStringDynamic(
  dynamic json, {
  bool ensureUniqueKey = true,
  bool throwOnDuplicate = false, // New parameter
}) {
  if (json is Map<dynamic, dynamic>) {
    final Map<String, dynamic> result = <String, dynamic>{};
    for (final MapEntry<dynamic, dynamic> entry in json.entries) {
      final String key = entry.key.toString();
      if (result.containsKey(key)) {
        if (throwOnDuplicate) {
          throw ArgumentError(
            'Duplicate key after toString() conversion: "$key" '
            '(from ${entry.key.runtimeType})',
          );
        }
        if (ensureUniqueKey) {
          continue; // Keep first occurrence
        }
        // else: fall through and overwrite (last wins)
      }
      result[key] = entry.value;
    }
    return result.isEmpty ? null : result;
  }
  // ... rest of method
}
```

---

## Missing Tests

No test covers duplicate key collisions after string conversion:

```dart
group('toMapStringDynamic key collision', () {
  test('int and string keys that collide after toString()', () {
    final map = <dynamic, dynamic>{1: 'int', '1': 'string'};

    final result = MapExtensions.toMapStringDynamic(
      map, ensureUniqueKey: true);
    // Should keep first occurrence
    expect(result?['1'], equals('int'));
    // AND the total count should be 1, not 2
    expect(result?.length, equals(1));
  });

  test('ensureUniqueKey false overwrites with last occurrence', () {
    final map = <dynamic, dynamic>{1: 'int', '1': 'string'};
    final result = MapExtensions.toMapStringDynamic(
      map, ensureUniqueKey: false);
    expect(result?['1'], equals('string')); // last wins
  });

  test('no collision with distinct keys', () {
    final map = <dynamic, dynamic>{1: 'one', 2: 'two', 'three': 3};
    final result = MapExtensions.toMapStringDynamic(map);
    expect(result?.length, equals(3));
  });
});
```
