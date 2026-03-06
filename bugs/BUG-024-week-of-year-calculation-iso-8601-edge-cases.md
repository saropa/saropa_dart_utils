# BUG-024: `weekOfYear` and `numOfWeeks()` Have ISO 8601 Week Calculation Errors

**File:** `lib/datetime/date_time_extensions.dart`
**Severity:** 🟡 Medium
**Category:** Logic Error / Edge Case
**Status:** Open

---

**Partial fix note (2026-03-06):** `weekNumber()` was added in `date_time_calendar_extensions.dart` for ISO 8601 boundary handling (early Jan → previous year’s last week, late Dec → week 1). The `weekOfYear` getter still uses the simplified formula; use `weekNumber()` for standards-compliant results. This bug remains open for full `weekOfYear`/`numOfWeeks` alignment if desired.

---

## Summary

The `weekOfYear` getter and `numOfWeeks()` method use a simplified algorithm that doesn't fully comply with ISO 8601 week numbering rules. This leads to incorrect week numbers at year boundaries, incorrect 53-week year detection, and potential off-by-one errors for dates in "week 1" of the next year or "week 52/53" of the previous year.

---

## ISO 8601 Week Rules (The Standard)

1. **Week 1** of a year is the week containing the **first Thursday** of that year (equivalently: the week containing January 4th).
2. A year has **53 weeks** if January 1st or December 31st is a Thursday.
3. Dates in early January can belong to **week 52/53 of the previous year**.
4. Dates in late December can belong to **week 1 of the next year**.

---

## Reproduction

```dart
// January 1, 2010 was a Friday
final jan1_2010 = DateTime(2010, 1, 1);
jan1_2010.weekOfYear;
// ❌ ACTUAL (estimated): week 1 (incorrect — should be week 53 of 2009)
// ✅ EXPECTED (ISO 8601): week 53 of year 2009

// December 31, 2012 was a Monday
final dec31_2012 = DateTime(2012, 12, 31);
dec31_2012.weekOfYear;
// ❌ ACTUAL (estimated): week 53 (incorrect — should be week 1 of 2013)
// ✅ EXPECTED (ISO 8601): week 1 of year 2013
```

---

## Root Cause

```dart
// lib/datetime/date_time_extensions.dart ~line 820
int get weekOfYear => ((dayOfYear - weekday + 10) / 7).floor();
```

This is a simplified formula that approximates ISO week numbers but doesn't handle year-crossing weeks. The `dayOfYear` for January 1 is 1, but ISO week numbering means that Jan 1 might be in week 52/53 of the *previous* year.

```dart
int numOfWeeks(int targetYear) {
  final DateTime dec28 = DateTime(targetYear, DateTime.december, 28);
  final DateTime jan1 = DateTime(targetYear);
  final int dayOfDec28 = dec28.difference(jan1).inDays + 1;
  return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
}
```

The December 28th approach is a known ISO heuristic (Dec 28 is always in the last week of the year), but the formula still uses the simplified `weekday` offset.

---

## Years Affected

Commonly mishandled years at boundaries:
- 2009: 53 weeks — Dec 31 2009 = week 53, Jan 1 2010 = week 53 of 2009
- 2015: 53 weeks — Jan 1 2015 = week 1, Dec 31 2015 = week 53
- 2020: 53 weeks — Jan 1 = week 1, Dec 31 = week 53
- Any year where Jan 1 or Dec 31 = Thursday

---

## Suggested Fix

Use a fully ISO-compliant algorithm. There are two approaches:

### Option A: Use a known-correct formula

```dart
int get weekOfYear {
  // ISO 8601 week number
  final DateTime thursday = subtract(Duration(days: weekday - DateTime.thursday));
  final int dayOfYear = thursday.difference(DateTime(thursday.year)).inDays + 1;
  return ((dayOfYear - 1) / 7).floor() + 1;
}
```

### Option B: Use `jiffy` (already a dependency!)

The project already includes `jiffy` as a dependency:

```dart
import 'package:jiffy/jiffy.dart';

int get weekOfYear => Jiffy.parseFromDateTime(this).weekOfYear;
```

This is the safest approach — `jiffy` handles all ISO 8601 edge cases correctly, and it's already in the project's `pubspec.yaml`.

---

## Missing Tests

```dart
group('weekOfYear - ISO 8601 edge cases', () {
  test('Jan 1 2010 (Friday) is week 53 of 2009', () {
    expect(DateTime(2010, 1, 1).weekOfYear, equals(53));
    // OR: check that year is 2009 if weekYear is exposed
  });

  test('Dec 31 2012 (Monday) is week 1 of 2013', () {
    expect(DateTime(2012, 12, 31).weekOfYear, equals(1));
  });

  test('Jan 4 is always in week 1', () {
    // True for any year
    for (int year = 2000; year <= 2025; year++) {
      expect(DateTime(year, 1, 4).weekOfYear, equals(1),
          reason: 'Jan 4 $year should be in week 1');
    }
  });

  test('numOfWeeks identifies 53-week years', () {
    // 2015 has 53 weeks (Jan 1 = Thursday)
    expect(DateTime(2015).numOfWeeks(2015), equals(53));
    // 2014 has 52 weeks
    expect(DateTime(2014).numOfWeeks(2014), equals(52));
  });
});
```
