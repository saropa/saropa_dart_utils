# SPEC: SimpleRelativeDay + getSimpleRelativeDay / getRelativeDayResult — for inclusion

**Status:** Proposed (from Saropa Contacts)
**Proposed location:** lib/datetime/simple_relative_day_utils.dart
**Portability:** Pure Dart for the classification core (enum + `getSimpleRelativeDay`). The weekday-name lookup in `getRelativeDayResult` uses `package:intl` (`DateFormat`) for a locale-aware weekday string. Proposal: keep the classification (`SimpleRelativeDay` + `getSimpleRelativeDay`) pure-Dart and `intl`-free; expose the weekday label as a caller-supplied formatter so the core stays dependency-free. The classification itself depends only on `DateTime` arithmetic and a `toDateOnly()` helper (the library already ships date-only helpers in `lib/datetime/`).

## Purpose — what it does + why it is general-purpose (not proprietary)

`getSimpleRelativeDay` classifies one `DateTime` relative to a reference `now` into a bounded set of human-relative calendar buckets, returning `null` when the date falls outside a ~2-month window. It answers "is this date Today / Yesterday / Tomorrow / the day before / the day after / a named weekday in the surrounding two weeks / next-or-last month?" using calendar-day arithmetic (time-of-day is dropped, so the result reflects calendar days, not elapsed 24-hour spans).

The bucketing rules, in order:

| Day delta (date − today, in calendar days) | Bucket |
|---|---|
| `0` | `Today` |
| `+1` | `Tomorrow` |
| `-1` | `Yesterday` |
| `+2` | `AfterTomorrow` |
| `-2` | `BeforeYesterday` |
| `+3 .. +6` | `NextWeekday` (+ weekday name) |
| `-6 .. -3` | `LastWeekday` (+ weekday name) |
| `+7 .. +13` | `NextWeekday` (+ weekday name) |
| `-13 .. -7` | `LastWeekday` (+ weekday name) |
| same calendar month, beyond the 2-week windows above | `null` |
| `monthDiff == +1` | `NextMonth` |
| `monthDiff == -1` | `LastMonth` |
| anything else (more than a month away) | `null` |

This is general-purpose: it is plain calendar classification with no app, contact, or domain coupling. It is widely useful for activity feeds, timelines, "recent items" grouping, and event lists — any UI that wants a compact relative-day label.

### Excluded members (app / locale coupled — NOT part of this spec)

| Member | Why excluded |
|---|---|
| `SimpleRelativeDay.displayName` getter | Returns `l10n.relativeDay*` — `AppLocalizations`-bound user-facing strings. Proprietary to the app's i18n catalog. The library would expose the enum and let callers map to their own strings. |
| `RelativeDayResult.displayLabel` getter | Concatenates `type.displayName` (l10n) with the weekday name. Depends on the excluded `displayName`. |
| Weekday-name formatting inside `getRelativeDayResult` | `DateFormat(DateFormat.WEEKDAY, LocaleUtils.getLocaleStringFromContext())` pulls the locale from the app's `BuildContext`/`LocaleUtils`. App-specific locale plumbing. The library should accept a caller-supplied formatter (e.g. `String Function(DateTime)`) instead of reaching into app locale state. |
| `debugException(error, stack)` in the catch block | App Crashlytics/debug reporting. Stripped below; the library should let the exception propagate or return `null` without app-specific logging. |

### Note on `weekdayName`

`getRelativeDayResult` currently bundles the locale-formatted weekday string into `RelativeDayResult.weekdayName`. For the library, the bucket classification (`SimpleRelativeDay`) is pure and the weekday label is a presentation concern. Recommendation: ship `getSimpleRelativeDay` returning just the enum (pure Dart), and offer an optional `getRelativeDayResult({String Function(DateTime)? weekdayFormatter})` overload where the caller injects the formatter — so the library never imports `intl` for this util and never touches app locale state.

## Overlap with installed library (saropa_dart_utils 1.4.1)

The library `lib/datetime/` already contains two related-but-distinct helpers — **partial overlap, not duplication**:

- **`relativeDateBucket(DateTime date, DateTime today)`** (`relative_date_bucket_utils.dart`) — buckets into `today` / `yesterday` / `last 7 days` / `last 30 days` / `older`. PAST-only, coarse, 5 fixed English string buckets, no future side, no weekday names, no `null` (always returns a bucket).
- **`relativeTimeString(DateTime, {DateTime? clock})`** (`date_time_relative_utils.dart`) — produces "2 hours ago" / "in 3 days" English phrases at sub-day granularity (seconds → years), symmetric past/future. Different output shape (free text, not an enum) and different granularity (includes intra-day).

**This util adds:** a typed enum (not a String) covering BOTH future and past at single-day resolution; the distinct named buckets `BeforeYesterday` / `AfterTomorrow`; the "named weekday within ±2 weeks" concept (`Last/NextWeekday`); the `Last/NextMonth` boundary; and a deliberate `null` return for "no useful relative label" (out of ~2-month range). Neither existing helper provides a future-aware, enum-typed, calendar-day classification with a null escape hatch. **Verdict: net-new (the enum-typed classifier), sitting alongside the two existing string helpers.**

## Source (from Saropa Contacts) — general-purpose members, verbatim (debug logging + l10n/locale stripped)

```dart
import 'package:intl/intl.dart';

/// Enum representing simple relative day categories with extended range.
enum SimpleRelativeDay {
  Today,
  Yesterday,
  Tomorrow,
  BeforeYesterday,
  AfterTomorrow,
  ThisWeek,
  LastWeek,
  NextWeek,
  ThisMonth,
  LastMonth,
  NextMonth,
  // For specific weekdays within 2 weeks
  LastWeekday,
  NextWeekday;
}

/// Result of relative day calculation, includes the type and optional weekday name.
class RelativeDayResult {
  const RelativeDayResult(this.type, {this.weekdayName});

  final SimpleRelativeDay type;
  final String? weekdayName;
}

/// Extension on DateTime for determining SimpleRelativeDay.
extension DateTimeSimpleRelativeDayExtension on DateTime {
  /// Determines the SimpleRelativeDay relative to [now].
  ///
  /// [now] defaults to current DateTime if not provided.
  /// Returns null if date is outside a reasonable range (~2 months).
  SimpleRelativeDay? getSimpleRelativeDay({DateTime? now}) {
    return getRelativeDayResult(now: now)?.type;
  }

  /// Gets the full relative day result including weekday name for
  /// "Last/Next Tuesday" etc.
  ///
  /// Library note: [weekdayFormatter] is caller-supplied so the core stays
  /// locale/intl free. In the app source this was a context-bound
  /// `DateFormat(DateFormat.WEEKDAY, <app locale>)`.
  RelativeDayResult? getRelativeDayResult({
    DateTime? now,
    String Function(DateTime)? weekdayFormatter,
  }) {
    now ??= DateTime.now();

    final DateTime today = now.toDateOnly();
    final DateTime dateOnly = toDateOnly();
    final int daysDiff = dateOnly.difference(today).inDays;

    // Exact matches first
    if (daysDiff == 0) {
      return const RelativeDayResult(SimpleRelativeDay.Today);
    }
    if (daysDiff == 1) {
      return const RelativeDayResult(SimpleRelativeDay.Tomorrow);
    }
    if (daysDiff == -1) {
      return const RelativeDayResult(SimpleRelativeDay.Yesterday);
    }
    if (daysDiff == 2) {
      return const RelativeDayResult(SimpleRelativeDay.AfterTomorrow);
    }
    if (daysDiff == -2) {
      return const RelativeDayResult(SimpleRelativeDay.BeforeYesterday);
    }

    // Weekday name for "Last/Next [Weekday]" labels.
    final String? weekdayName =
        weekdayFormatter?.call(dateOnly) ??
        DateFormat(DateFormat.WEEKDAY).format(dateOnly);

    // Within the same week (3-6 days away)
    if (daysDiff >= 3 && daysDiff <= 6) {
      return RelativeDayResult(SimpleRelativeDay.NextWeekday, weekdayName: weekdayName);
    }
    if (daysDiff >= -6 && daysDiff <= -3) {
      return RelativeDayResult(SimpleRelativeDay.LastWeekday, weekdayName: weekdayName);
    }

    // Next week (7-13 days ahead)
    if (daysDiff >= 7 && daysDiff <= 13) {
      return RelativeDayResult(SimpleRelativeDay.NextWeekday, weekdayName: weekdayName);
    }

    // Last week (7-13 days ago)
    if (daysDiff >= -13 && daysDiff <= -7) {
      return RelativeDayResult(SimpleRelativeDay.LastWeekday, weekdayName: weekdayName);
    }

    // Check month differences
    final int monthDiff =
        (dateOnly.year - today.year) * 12 + dateOnly.month - today.month;

    if (monthDiff == 0) {
      // Same month but more than 2 weeks away - no label needed
      return null;
    }
    if (monthDiff == 1) {
      return const RelativeDayResult(SimpleRelativeDay.NextMonth);
    }
    if (monthDiff == -1) {
      return const RelativeDayResult(SimpleRelativeDay.LastMonth);
    }

    // More than a month away - no relative label
    return null;
  }
}
```

> **Dead enum values:** `ThisWeek`, `LastWeek`, `NextWeek`, `ThisMonth` are declared on the enum but never returned by `getRelativeDayResult`. The classifier emits `Last/NextWeekday` for the week range, never `Last/NextWeek`, and never `ThisWeek`/`ThisMonth`. Before library inclusion, decide: either remove the four unreachable values, or wire them in (e.g. `ThisMonth` for the `monthDiff == 0` beyond-2-weeks case currently returning `null`). Flag for the library owner — do not import the dead values silently.
>
> **`toDateOnly()` dependency:** the app calls `DateTime.toDateOnly()` (truncate to midnight, preserving the existing `DateTime`'s UTC-vs-local kind). The library must provide an equivalent date-only normalizer. Document the UTC/local-kind behavior: `now` and the receiver should be the same kind, or the `inDays` delta can be off by one across a DST or UTC offset boundary.

## Test cases — existing tests (Saropa Contacts), verbatim

From `test/utils/primitive/date_time/date_time_utils_test.dart` (group `SimpleRelativeDay`). The `displayLabel` / `displayName` assertions below exercise the EXCLUDED l10n members and would be replaced by enum-`type` + `weekdayName` assertions in the library; they are reproduced verbatim so the intended classification is unambiguous.

```dart
group('SimpleRelativeDay', () {
  group('getSimpleRelativeDay', () {
    test('returns Today for same day', () {
      final DateTime now = DateTime(2024, 12, 29, 10, 30);
      final DateTime date = DateTime(2024, 12, 29, 15, 45);

      expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.Today);
    });

    test('returns Yesterday for previous day', () {
      final DateTime now = DateTime(2024, 12, 29);
      final DateTime date = DateTime(2024, 12, 28);

      expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.Yesterday);
    });

    test('returns Tomorrow for next day', () {
      final DateTime now = DateTime(2024, 12, 29);
      final DateTime date = DateTime(2024, 12, 30);

      expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.Tomorrow);
    });

    test('returns BeforeYesterday for 2 days ago', () {
      final DateTime now = DateTime(2024, 12, 29);
      final DateTime date = DateTime(2024, 12, 27);

      expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.BeforeYesterday);
    });

    test('returns AfterTomorrow for 2 days ahead', () {
      final DateTime now = DateTime(2024, 12, 29);
      final DateTime date = DateTime(2024, 12, 31);

      expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.AfterTomorrow);
    });

    test('returns NextWeekday for 3-6 days ahead', () {
      final DateTime now = DateTime(2024, 12, 29); // Sunday
      final DateTime date = DateTime(2025, 1, 1); // Wednesday, 3 days ahead

      expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.NextWeekday);
    });

    test('returns LastWeekday for 3-6 days ago', () {
      final DateTime now = DateTime(2024, 12, 29); // Sunday
      final DateTime date = DateTime(2024, 12, 25); // Wednesday, 4 days ago

      expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.LastWeekday);
    });

    test('returns NextWeekday for 7-13 days ahead', () {
      final DateTime now = DateTime(2024, 12, 29);
      final DateTime date = DateTime(2025, 1, 7); // 9 days ahead

      expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.NextWeekday);
    });

    test('returns LastWeekday for 7-13 days ago', () {
      final DateTime now = DateTime(2024, 12, 29);
      final DateTime date = DateTime(2024, 12, 19); // 10 days ago

      expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.LastWeekday);
    });

    test('returns NextMonth for dates in the next month', () {
      final DateTime now = DateTime(2024, 12, 29);
      final DateTime date = DateTime(2025, 1, 20); // 22 days ahead, next month

      expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.NextMonth);
    });

    test('returns LastMonth for dates in the previous month', () {
      final DateTime now = DateTime(2024, 12, 29);
      final DateTime date = DateTime(2024, 11, 15); // Previous month

      expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.LastMonth);
    });

    test('returns null for same month but more than 2 weeks away', () {
      final DateTime now = DateTime(2024, 12, 1);
      final DateTime date = DateTime(2024, 12, 25); // 24 days ahead, same month

      expect(date.getSimpleRelativeDay(now: now), isNull);
    });

    test('returns null for dates more than a month away', () {
      final DateTime now = DateTime(2024, 12, 29);
      final DateTime date = DateTime(2025, 3, 15); // Several months ahead

      expect(date.getSimpleRelativeDay(now: now), isNull);
    });
  });

  group('getRelativeDayResult', () {
    test('returns correct displayLabel for Today', () {
      final DateTime now = DateTime(2024, 12, 29);
      final DateTime date = DateTime(2024, 12, 29);

      final RelativeDayResult? result = date.getRelativeDayResult(now: now);
      expect(result?.displayLabel, 'Today');
    });

    test('returns correct displayLabel for Yesterday', () {
      final DateTime now = DateTime(2024, 12, 29);
      final DateTime date = DateTime(2024, 12, 28);

      final RelativeDayResult? result = date.getRelativeDayResult(now: now);
      expect(result?.displayLabel, 'Yesterday');
    });

    test('returns correct displayLabel for Tomorrow', () {
      final DateTime now = DateTime(2024, 12, 29);
      final DateTime date = DateTime(2024, 12, 30);

      final RelativeDayResult? result = date.getRelativeDayResult(now: now);
      expect(result?.displayLabel, 'Tomorrow');
    });

    test('returns correct displayLabel for Day Before Yesterday', () {
      final DateTime now = DateTime(2024, 12, 29);
      final DateTime date = DateTime(2024, 12, 27);

      final RelativeDayResult? result = date.getRelativeDayResult(now: now);
      expect(result?.displayLabel, 'Day Before Yesterday');
    });

    test('returns correct displayLabel for Day After Tomorrow', () {
      final DateTime now = DateTime(2024, 12, 29);
      final DateTime date = DateTime(2024, 12, 31);

      final RelativeDayResult? result = date.getRelativeDayResult(now: now);
      expect(result?.displayLabel, 'Day After Tomorrow');
    });

    test('returns "Next Wednesday" for 3 days ahead on a Sunday', () {
      final DateTime now = DateTime(2024, 12, 29); // Sunday
      final DateTime date = DateTime(2025, 1, 1); // Wednesday

      final RelativeDayResult? result = date.getRelativeDayResult(now: now);
      expect(result?.displayLabel, 'Next Wednesday');
    });

    test('returns "Last Wednesday" for Christmas when today is Sunday Dec 29', () {
      final DateTime now = DateTime(2024, 12, 29); // Sunday
      final DateTime date = DateTime(2024, 12, 25); // Wednesday

      final RelativeDayResult? result = date.getRelativeDayResult(now: now);
      expect(result?.displayLabel, 'Last Wednesday');
    });

    test('returns "Next Monday" for 7 days ahead', () {
      final DateTime now = DateTime(2024, 12, 29); // Sunday
      final DateTime date = DateTime(
        2025,
        1,
        5,
      ); // Sunday + 7 = next Sunday? No, Jan 5 is Sunday

      final RelativeDayResult? result = date.getRelativeDayResult(now: now);
      expect(result?.displayLabel, 'Next Sunday');
    });

    test('returns "Last Sunday" for 7 days ago', () {
      final DateTime now = DateTime(2024, 12, 29); // Sunday
      final DateTime date = DateTime(2024, 12, 22); // Previous Sunday

      final RelativeDayResult? result = date.getRelativeDayResult(now: now);
      expect(result?.displayLabel, 'Last Sunday');
    });

    test('returns "Next Month" for dates in next calendar month beyond 2 weeks', () {
      final DateTime now = DateTime(2024, 12, 15);
      final DateTime date = DateTime(2025, 1, 20); // Next month, 36 days ahead

      final RelativeDayResult? result = date.getRelativeDayResult(now: now);
      expect(result?.displayLabel, 'Next Month');
    });

    test('returns "Last Month" for dates in previous calendar month', () {
      final DateTime now = DateTime(2024, 12, 29);
      final DateTime date = DateTime(2024, 11, 10); // Previous month

      final RelativeDayResult? result = date.getRelativeDayResult(now: now);
      expect(result?.displayLabel, 'Last Month');
    });

    test('returns null for dates several months away', () {
      final DateTime now = DateTime(2024, 12, 29);
      final DateTime date = DateTime(2025, 6, 15);

      final RelativeDayResult? result = date.getRelativeDayResult(now: now);
      expect(result, isNull);
    });
  });

  group('edge cases', () {
    test('handles year boundary correctly for Tomorrow', () {
      final DateTime now = DateTime(2024, 12, 31);
      final DateTime date = DateTime(2025, 1, 1);

      expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.Tomorrow);
    });

    test('handles year boundary correctly for Yesterday', () {
      final DateTime now = DateTime(2025, 1, 1);
      final DateTime date = DateTime(2024, 12, 31);

      expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.Yesterday);
    });

    test('handles leap year February 29', () {
      final DateTime now = DateTime(2024, 2, 28); // Leap year
      final DateTime date = DateTime(2024, 2, 29);

      expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.Tomorrow);
    });

    test('handles month boundary for NextMonth', () {
      final DateTime now = DateTime(2024, 1, 31);
      final DateTime date = DateTime(2024, 2, 15);

      expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.NextMonth);
    });

    test('handles month boundary for LastMonth', () {
      final DateTime now = DateTime(2024, 2, 1);
      final DateTime date = DateTime(2024, 1, 15);

      expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.LastMonth);
    });

    test('time of day does not affect result', () {
      final DateTime now = DateTime(2024, 12, 29, 23, 59, 59);
      final DateTime date = DateTime(2024, 12, 30, 0, 0, 1);

      expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.Tomorrow);
    });

    test('exactly midnight dates work correctly', () {
      final DateTime now = DateTime(2024, 12, 29, 0, 0, 0);
      final DateTime date = DateTime(2024, 12, 29, 0, 0, 0);

      expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.Today);
    });
  });

  group('RelativeDayResult', () {
    test('displayLabel returns displayName when weekdayName is null', () {
      const RelativeDayResult result = RelativeDayResult(SimpleRelativeDay.Today);
      expect(result.displayLabel, 'Today');
    });

    test('displayLabel combines displayName and weekdayName', () {
      const RelativeDayResult result = RelativeDayResult(
        SimpleRelativeDay.NextWeekday,
        weekdayName: 'Friday',
      );
      expect(result.displayLabel, 'Next Friday');
    });

    test('displayLabel for LastWeekday with weekday', () {
      const RelativeDayResult result = RelativeDayResult(
        SimpleRelativeDay.LastWeekday,
        weekdayName: 'Monday',
      );
      expect(result.displayLabel, 'Last Monday');
    });
  });
});
```

> When ported to the library, the `displayLabel` / `displayName` assertions are dropped (those members are excluded) and replaced with `result?.type` + `result?.weekdayName` assertions, e.g. the "Next Wednesday" test becomes:
> ```dart
> final RelativeDayResult? result = date.getRelativeDayResult(now: now);
> expect(result?.type, SimpleRelativeDay.NextWeekday);
> expect(result?.weekdayName, 'Wednesday');
> ```

## Bulletproofing gaps — concrete edge cases to add for massive coverage

**Exact bucket boundaries (off-by-one is the dominant failure mode here):**
- `daysDiff == +2` and `+3` (boundary between `AfterTomorrow` and `NextWeekday`).
- `daysDiff == -2` and `-3` (boundary between `BeforeYesterday` and `LastWeekday`).
- `daysDiff == +6` and `+7` (both map to `NextWeekday`, but cross the 3-6 / 7-13 internal branch — assert no gap or double-bucket).
- `daysDiff == +13` and `+14` (last `NextWeekday` vs falling through to month logic).
- `daysDiff == -13` and `-14` (last `LastWeekday` vs falling through).
- `daysDiff == -6` and `-7` (internal `LastWeekday` branch crossing).

**The `null` boundary / `monthDiff` interaction (the subtle zone):**
- Date `+14` to `+20` in the SAME calendar month as `now` → currently `null` (e.g. `now = Dec 1`, `date = Dec 25` is 24 days, same month → `null`). Lock this.
- Date `+14` that lands in the NEXT calendar month → `NextMonth` (e.g. `now = Jan 20`, `date = Feb 3`, 14 days, `monthDiff == 1`). Confirms month-diff wins over the 2-week window once past day 13.
- `monthDiff == +1` but the day delta is large (e.g. `now = Jan 1`, `date = Feb 28`, ~58 days) → still `NextMonth`. Confirms `NextMonth` is unbounded in days as long as `monthDiff == 1`.
- `monthDiff == +2` → `null`. And `monthDiff == -2` → `null`.
- Cross-year `monthDiff`: `now = Dec 2024`, `date = Jan 2025` → `monthDiff == 1` → `NextMonth` (the `(year-year)*12 + month-month` formula must handle the year rollover; add an explicit Dec→Jan and Jan→Dec test).

**Month-length / leap edge cases:**
- Leap Feb 29 as `now` AND as `date` (both directions): `now = Feb 29 2024`, `date = Mar 1 2024` → `Tomorrow`; `date = Feb 28 2024` → `Yesterday`.
- 31-day vs 30-day month boundaries: `now = Jan 31`, `date = Mar 1` (skips short Feb) — assert the `monthDiff` formula (`== 2`) returns `null`, not a weekday bucket.
- `now = Mar 31`, `date = Feb 28` (`monthDiff == -1`) → `LastMonth`.

**DST / time-zone kind (the real correctness risk for `inDays`):**
- DST "spring forward" day: a local `DateTime` where the day is only 23 hours — confirm `toDateOnly().difference().inDays` still yields whole calendar days (the date-only truncation must remove the partial-hour error). Add a test in a DST-observing zone, or document that callers must pass same-kind values.
- Mixed kind: `now` is `DateTime.utc(...)` and `date` is local (or vice versa). `difference()` is computed in absolute time, so a UTC/local mix can shift the day by the offset. Add a test that asserts the documented behavior (either normalize both to the same kind internally, or require same-kind and test that the mismatch is the caller's responsibility).
- Exactly-midnight UTC vs local around an offset boundary.

**Extremes / degenerate inputs:**
- `date == now` exactly (already covered) plus `date` one microsecond before/after midnight — confirm time component is fully dropped.
- `DateTime` at the far extremes (`DateTime(1, 1, 1)`, `DateTime(275760, 9, 13)` — Dart's max) as both `now` and `date`; confirm no overflow in `(year - year) * 12` and that far-apart values return `null` rather than throwing.
- `now` defaulting to `DateTime.now()` when omitted — pass only `date` and assert it does not throw (can't assert exact bucket; assert non-throwing + type).

**Dead-value guard:**
- Add a test asserting `getRelativeDayResult` NEVER returns `ThisWeek`, `LastWeek`, `NextWeek`, or `ThisMonth` for any delta in `-400 .. +400` days — this both documents the dead values and catches a regression if someone wires them in incorrectly. (Or, if the values are removed, this test is deleted.)

**Weekday formatter (library overload):**
- `weekdayFormatter` returns the expected weekday string for a known date (inject a stub formatter; assert `weekdayName` is forwarded verbatim).
- `weekdayFormatter` is `null` and the exact-match buckets (`Today`/`Tomorrow`/etc.) are returned — assert `weekdayName` is `null` for those (formatter is never invoked).
- A throwing `weekdayFormatter` — decide and test: does the classification still return the correct `type` with `weekdayName == null`, or does the exception propagate? (App version swallowed it via `debugException`; library should make this explicit.)

Note: emoji / unicode / empty-string / NaN / infinity inputs are **not applicable** — every input is a `DateTime`, which cannot carry those. The relevant "extreme" axis is the DateTime value range and the UTC/local kind, covered above.
