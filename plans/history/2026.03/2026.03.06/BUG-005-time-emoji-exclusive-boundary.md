# BUG-005: `timeToEmoji` Uses Wrong Comparison Operators — 7am Shows Moon

**File:** `lib/datetime/time_emoji_utils.dart`, `lib/datetime/date_constants.dart`
**Severity:** 🟡 Medium
**Category:** Logic Error / Off-by-One
**Status:** Open

---

## Summary

The time-to-emoji conversion uses strict `>` and `<` comparisons against `dayStartHour = 7` and `dayEndHour = 18`. This means at exactly 7:00 AM, a moon emoji is returned (not a sun), and at exactly 6:00 PM (18:00), a moon emoji is returned — contrary to the documented intent of "daytime = 7am to 6pm".

---

## Reproduction

```dart
// 7:00 AM — should be day (sun) but gets night (moon)
final sevenAm = DateTime(2024, 6, 15, 7, 0, 0);
print(sevenAm.toTimeEmoji()); // ❌ Returns moon 🌙

// 6:59 AM — correctly returns moon
final sixFiftyNineAm = DateTime(2024, 6, 15, 6, 59, 0);
print(sixFiftyNineAm.toTimeEmoji()); // ✅ Returns moon 🌙

// 8:00 AM — correctly returns sun
final eightAm = DateTime(2024, 6, 15, 8, 0, 0);
print(eightAm.toTimeEmoji()); // ✅ Returns sun ☀️

// 6:00 PM (18:00) — boundary, should be end of day (sun) but returns moon
final sixPm = DateTime(2024, 6, 15, 18, 0, 0);
print(sixPm.toTimeEmoji()); // ❌ Returns moon 🌙
```

---

## Root Cause

```dart
// lib/datetime/date_constants.dart ~line 34
/// Hour threshold for start of "day" time (after 7am).
const int dayStartHour = 7;
/// Hour threshold for end of "day" time (before 6pm/18:00).
const int dayEndHour = 18;
```

```dart
// lib/datetime/time_emoji_utils.dart ~line 27
return tzHour > dayStartHour && tzHour < dayEndHour
//            ^                         ^
//     strict greater-than        strict less-than
//     Excludes hour 7!            Excludes hour 18!
    ? sunEmoji
    : moonEmoji;
```

The documentation says "after 7am" which is ambiguous — "after" could mean exclusive of 7, but most users expect 7am to show a sun. The intent, based on the constant name `dayStartHour`, is that 7 is the *start of day*, meaning it should be inclusive.

---

## Impact

- 7:00 AM displays a moon emoji despite being a reasonable daytime hour.
- The discrepancy between the documented "after 7am" and the implemented `> 7` creates confusion.
- Any UI displaying a time indicator or greeting based on this function will show wrong icons at these boundary hours.

---

## Docstring Contradiction

The constant comment says:
```dart
/// Hour threshold for start of "day" time (after 7am).
```

But the variable is named `dayStartHour` — if it's the "start hour of day", it should be the first hour shown with the day emoji, i.e., `>=`, not `>`.

---

## Suggested Fix

```dart
// lib/datetime/time_emoji_utils.dart
return tzHour >= dayStartHour && tzHour < dayEndHour
//            ^^
//     inclusive — 7am IS daytime
    ? sunEmoji
    : moonEmoji;
```

And update the constant comment to match:

```dart
// lib/datetime/date_constants.dart
/// First hour of "day" time, inclusive (7am shows sun emoji).
const int dayStartHour = 7;
/// First hour of "night" time, exclusive (18:00/6pm shows moon emoji).
const int dayEndHour = 18;
```

---

## Missing Tests

The test file for `time_emoji_utils_test.dart` should test these exact boundary conditions:

```dart
group('boundary hours', () {
  test('7am returns sun (day start, inclusive)', () {
    final dt = DateTime(2024, 6, 15, 7, 0);
    expect(TimeEmojiUtils.timeToEmoji(dt), equals('☀️'));
  });

  test('6:59am returns moon (before day start)', () {
    final dt = DateTime(2024, 6, 15, 6, 59);
    expect(TimeEmojiUtils.timeToEmoji(dt), equals('🌙'));
  });

  test('5:59pm (17:59) returns sun (still daytime)', () {
    final dt = DateTime(2024, 6, 15, 17, 59);
    expect(TimeEmojiUtils.timeToEmoji(dt), equals('☀️'));
  });

  test('6pm (18:00) returns moon (day end, exclusive)', () {
    final dt = DateTime(2024, 6, 15, 18, 0);
    expect(TimeEmojiUtils.timeToEmoji(dt), equals('🌙'));
  });
});
```
