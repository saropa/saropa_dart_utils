# BUG-026: Duplicate Test Cases in `date_time_range_utils_test.dart`

**File:** `test/datetime/date_time_range_utils_test.dart`
**Severity:** 🟢 Low
**Category:** Test Quality
**Status:** Open

---

## Summary

`date_time_range_utils_test.dart` contains duplicate test cases for the same scenarios — identical inputs/assertions appearing in multiple test groups. Duplicate tests waste CI time, create false confidence (appearing to have more coverage than exists), and can lead to inconsistency if one copy is updated but the other is not.

---

## Known Duplicates

### Duplicate 1: "5th Monday of February — doesn't exist"
**Lines:** ~55-63 AND ~159-167

Both tests check the same input (finding the 5th Monday of February when it doesn't exist) with the same expected output (`null`). One is in a group and one is a standalone test.

```dart
// Appears twice in the same test file:
test('5th Monday of February - doesn\'t exist', () {
  final result = DateTimeRangeUtils.nthWeekdayOfMonth(
    year: 2024, month: 2, weekday: DateTime.monday, n: 5);
  expect(result, isNull);
});
```

### Duplicate 2: Similar boundary conditions tested in overlapping groups
**Lines:** ~101-107 AND ~183-191

Both test the same concept (last day of month boundary) with slight name variations but identical logic.

---

## Impact

- Test suite runs slower than necessary.
- Coverage reports appear more comprehensive than they are.
- If behavior changes, only one copy may be updated — tests diverge silently.
- Developers reviewing failing tests see the same failure twice, increasing confusion.

---

## How to Find All Duplicates

```bash
# Run from project root to find potentially duplicated test descriptions
grep -n "test\|group" test/datetime/date_time_range_utils_test.dart | sort
```

---

## Suggested Fix

1. Remove the duplicate test cases, keeping the most descriptive version.
2. If the same scenario appears in different groups for a reason (testing different code paths), add a comment explaining why both are needed.
3. Consider extracting shared test data into variables to make it obvious when two tests test the same thing:

```dart
// Extract shared test parameters to detect duplication
const int yearFor5thMonday = 2024;
const int monthFeb = 2;

// Only one test using these values:
test('5th Monday of February 2024 returns null (doesn\'t exist)', () {
  expect(
    DateTimeRangeUtils.nthWeekdayOfMonth(
      year: yearFor5thMonday, month: monthFeb,
      weekday: DateTime.monday, n: 5),
    isNull,
  );
});
```
