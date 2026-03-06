# BUG-017: `UuidUtils.addHyphens()` Accepts Non-Hex Input Without Validation

**File:** `lib/uuid/uuid_utils.dart`
**Severity:** 🟡 Medium
**Category:** Logic Error / Validation Gap
**Status:** Open

---

## Summary

`UuidUtils.addHyphens()` validates the *length* of the input (must be 32 characters) but does not validate that the content is valid hexadecimal. Any 32-character string will have hyphens inserted and be returned as if it were a valid UUID — even completely invalid content like `'zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz'`.

---

## Reproduction

```dart
// Valid UUID (all hex chars)
UuidUtils.addHyphens('550e8400e29b41d4a716446655440000');
// ✅ Returns '550e8400-e29b-41d4-a716-446655440000'

// Invalid hex content (z is not hex)
UuidUtils.addHyphens('zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz');
// ❌ Returns 'zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz'
// Should return null

// Non-UUID random string of length 32
UuidUtils.addHyphens('thisIsNotAValidUuidButHasLen32!!');
// ❌ Returns 'thisIsNo-tANo-tAVa-lidU-uidButHasLen' + some chars
// Should return null
```

---

## Root Cause

```dart
// lib/uuid/uuid_utils.dart ~line 105
static String? addHyphens(String? uuid) {
  if (uuid == null || uuid.isEmpty) return null;
  if (uuid.contains('-')) return uuid;                        // Already has hyphens
  if (uuid.length != _uuidLengthWithoutHyphens) return null; // Length check only

  // No hex validation — just inserts hyphens at fixed positions
  final StringBuffer sb = StringBuffer()
    ..write(uuid.substring(0, _segment1End))
    ..write('-')
    ..write(uuid.substring(_segment1End, _segment2End))
    ..write('-')
    ..write(uuid.substring(_segment2End, _segment3End))
    ..write('-')
    ..write(uuid.substring(_segment3End, _segment4End))
    ..write('-')
    ..write(uuid.substring(_segment4End));
  return sb.toString();
}
```

---

## Contrast with Validation Methods

The same file has rigorous UUID validation:

```dart
// lib/uuid/uuid_utils.dart ~line 15
final RegExp _uuidWithHyphensRegex = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  caseSensitive: false,
);
```

But `addHyphens` doesn't use this validation at all. There's also a validation method `isValidUuid()` that could be called after adding hyphens, but it's not.

---

## Impact

- Applications accepting UUID input from users or APIs may silently convert garbage strings into pseudo-UUIDs.
- The resulting fake UUID would pass downstream length checks but fail any regex-based validation.
- The inconsistency between `addHyphens` (lenient) and `isValidUuid` (strict) creates a confusing API.

---

## Suggested Fix

Add hex character validation before inserting hyphens:

```dart
static String? addHyphens(String? uuid) {
  if (uuid == null || uuid.isEmpty) return null;
  if (uuid.contains('-')) return uuid; // Already has hyphens — validate separately
  if (uuid.length != _uuidLengthWithoutHyphens) return null;

  // Validate all characters are valid hexadecimal
  if (!RegExp(r'^[0-9a-fA-F]{32}$').hasMatch(uuid)) return null;

  final StringBuffer sb = StringBuffer()
    ..write(uuid.substring(0, _segment1End))
    ..write('-')
    // ... rest unchanged
  return sb.toString();
}
```

---

## Missing Tests

```dart
group('addHyphens - input validation', () {
  test('valid hex string gets hyphens', () {
    expect(
      UuidUtils.addHyphens('550e8400e29b41d4a716446655440000'),
      equals('550e8400-e29b-41d4-a716-446655440000'),
    );
  });

  test('non-hex 32-char string returns null', () {
    expect(
      UuidUtils.addHyphens('zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz'),
      isNull,
    );
  });

  test('mixed valid/invalid hex returns null', () {
    // Last char 'z' is not hex
    expect(
      UuidUtils.addHyphens('550e8400e29b41d4a71644665544000z'),
      isNull,
    );
  });

  test('uppercase hex is accepted', () {
    expect(
      UuidUtils.addHyphens('550E8400E29B41D4A716446655440000'),
      isNotNull,
    );
  });
});
```
