# BUG-032: `forceBetween()` Has a Grammatically Incorrect, Contradictory Comment

**File:** `lib/int/int_extensions.dart`
**Severity:** 🟢 Low
**Category:** Documentation
**Status:** Open

---

## Summary

The dartdoc comment for `forceBetween()` says "Ensure NOT this greater than or equal to [from]" — which is grammatically broken and semantically backwards. The actual method *clamps* the value to be within the range, not *outside* it.

---

## Root Cause

```dart
// lib/int/int_extensions.dart ~line 59
/// Ensure NOT this greater than
/// or equal to [from] and less than or equal to [to]?
int forceBetween(int from, final int to) {
```

Reading the comment literally: it's saying "ensure this is NOT greater than or equal to [from]" — which would mean "ensure `this < from`". That's the opposite of what the method does.

The same misleading comment likely exists in `double_extensions.dart` for the double version.

---

## Suggested Fix

```dart
/// Clamps this integer to be within the inclusive range [[from], [to]].
///
/// Returns [from] if this is less than [from].
/// Returns [to] if this is greater than [to].
/// Returns this unchanged if already within the range.
/// Returns this unchanged if [from] > [to] (invalid range).
///
/// Example:
/// ```dart
/// 5.forceBetween(1, 10);  // 5 (within range)
/// 0.forceBetween(1, 10);  // 1 (below range → clamped to from)
/// 15.forceBetween(1, 10); // 10 (above range → clamped to to)
/// ```
int forceBetween(int from, final int to) {
```

Apply the same fix to `lib/double/double_extensions.dart` for the double version.
