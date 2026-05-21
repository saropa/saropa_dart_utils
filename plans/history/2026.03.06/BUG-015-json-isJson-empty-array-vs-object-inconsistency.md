# BUG-015: `isJson()` Accepts Empty Array `[]` but Rejects Empty Object `{}`

**File:** `lib/json/json_utils.dart`
**Severity:** 🟡 Medium
**Category:** Logic Error / API Inconsistency
**Status:** Open

---

## Summary

`isJson('[]')` returns `true` without requiring `allowEmpty: true`. `isJson('{}')` returns `false` unless `allowEmpty: true` is passed. Both `[]` and `{}` are valid JSON values — the inconsistency is a bug.

---

## Reproduction

```dart
JsonUtils.isJson('[]');                    // ✅ true  — but should require allowEmpty?
JsonUtils.isJson('{}');                    // ❌ false — requires allowEmpty: true
JsonUtils.isJson('{}', allowEmpty: true);  // ✅ true

// Also:
JsonUtils.isJson('[1, 2, 3]');            // ✅ true
JsonUtils.isJson('{"key": "value"}');     // ✅ true
```

---

## Root Cause

```dart
// lib/json/json_utils.dart ~line 66
static bool isJson(String? value, {bool testDecode = false, bool allowEmpty = false}) {
  if (value == null || value.length < 2) return false;
  final String trimmed = value.trim();
  final bool isObject = trimmed.startsWith('{') && trimmed.endsWith('}');
  final bool isArray  = trimmed.startsWith('[') && trimmed.endsWith(']');
  if (!isObject && !isArray) return false;

  if (isObject && !value.contains(':')) {
    if (!allowEmpty || trimmed != '{}') return false;
    //  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    //  Empty object requires allowEmpty flag
  }
  // NO equivalent check for empty arrays!
  // An empty array '[]' passes right through to the next checks
  // because it never hits the isObject branch
  ...
}
```

The `isArray` case never checks for emptiness. `[]` contains no `:` but the `:` check only applies to `isObject`.

---

## Impact

- Code relying on `isJson()` to validate input may incorrectly accept `[]` as valid JSON where only non-empty JSON is expected.
- The `allowEmpty` parameter is misleading — it only controls `{}`, not `[]`.
- This inconsistency will confuse callers trying to use `allowEmpty` to "require non-empty" JSON.

---

## Also Related: `tryJsonDecodeListMap()` and `tryJsonDecodeList()` Return Null for Empty Arrays

```dart
// lib/json/json_utils.dart ~line 109
static List<Map<String, dynamic>>? tryJsonDecodeListMap(String? value) {
  if (value == null || !isJson(value)) return null;
  try {
    final dynamic data = dc.json.decode(value);
    if (data is! List || data.isEmpty || data[0] is! Map<String, dynamic>) return null;
    //                    ^^^^^^^^^^^
    //                    Empty list treated the same as invalid JSON — returns null
    return data.cast<Map<String, dynamic>>();
  } ...
}
```

An empty JSON array `[]` is valid JSON. `tryJsonDecodeListMap('[]')` should return `[]` (an empty list), not `null`. The current behavior forces callers to check for `null` to mean both "invalid JSON" AND "empty list" — losing the distinction.

Same problem in `tryJsonDecodeList()`:
```dart
if (data is! List || data.isEmpty) return null; // ← Empty array returns null!
```

---

## Suggested Fix

### For `isJson()`
```dart
if (isObject && !value.contains(':')) {
  if (!allowEmpty || trimmed != '{}') return false;
}
if (isArray && !value.contains(',') && trimmed.length == 2) {
  // Empty array '[]'
  if (!allowEmpty) return false;
}
```

Or more simply — make `allowEmpty` control both types consistently:

```dart
// Check for empty containers
if (isObject && trimmed == '{}') {
  return allowEmpty;
}
if (isArray && trimmed == '[]') {
  return allowEmpty;
}
```

### For `tryJsonDecodeListMap()`
```dart
if (data is! List) return null;
if (data.isEmpty) return <Map<String, dynamic>>[]; // Valid empty list
if (data[0] is! Map<String, dynamic>) return null;
return data.cast<Map<String, dynamic>>();
```

### For `tryJsonDecodeList()`
```dart
if (data is! List) return null;
if (data.isEmpty) return <String>[]; // Valid empty list
if (!data.every((dynamic e) => e is String)) return null;
return data.cast<String>();
```

---

## Missing Tests

```dart
group('isJson consistency', () {
  test('empty array and empty object treated consistently', () {
    final emptyArray = JsonUtils.isJson('[]');
    final emptyObject = JsonUtils.isJson('{}');
    // Both should behave the same
    expect(emptyArray, equals(emptyObject));
  });

  test('empty array with allowEmpty:true', () {
    expect(JsonUtils.isJson('[]', allowEmpty: true), isTrue);
  });
});

group('tryJsonDecodeListMap', () {
  test('empty array returns empty list, not null', () {
    expect(JsonUtils.tryJsonDecodeListMap('[]'), equals([]));
    // NOT: expect(result, isNull)
  });
});

group('tryJsonDecodeList', () {
  test('empty array returns empty list, not null', () {
    expect(JsonUtils.tryJsonDecodeList('[]'), equals([]));
  });
});
```
