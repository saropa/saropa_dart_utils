# SPEC: RelativeTimeUtils (isTomorrow / isYesterday / isOlderThanToday / isOlderThanYesterday / relativeTime) — for inclusion

**Status:** Proposed (from Saropa Contacts)
**Proposed location:** lib/datetime/date_time_relative_predicate_extensions.dart (predicates) + an additive `relativeTimeDescriptive` in/near lib/datetime/date_time_relative_utils.dart
**Portability:** Pure Dart. No Flutter, no external packages. Depends only on members already in saropa_dart_utils — `isSameDateOnly` (date_time_comparison_extensions.dart), `String.isNullOrEmpty`, and `String.pluralize`. No `intl`/`quiver`.

## Purpose — what it does + why it is general-purpose (not proprietary)

`RelativeTimeUtils` is a `DateTime` extension with two general-purpose halves:

1. **Calendar-day predicates** — `isTomorrow`, `isYesterday`, `isOlderThanToday`, `isOlderThanYesterday`. Each accepts an optional `now` reference (defaults to `DateTime.now()`) for deterministic testing. They compare on date-only boundaries (start-of-day), so the time component is irrelevant. These are everyday "is this date adjacent to / before today" checks with no app-specific logic.

2. **A descriptive relative-time formatter** — `relativeTime({now, isDescriptive, isDescriptiveTimeSuffix, roundUp})` returns strings such as `"a moment ago"`, `"5 minutes ago"`, `"about an hour from now"`, `"2 years ago"`, or a terse form (`"5 min ago"`, `"~1h"`, `"2y"`) when `isDescriptive: false`. It uses a proper date-based year algorithm (not `days / 365.25`) to avoid off-by-one errors near anniversary boundaries, supports past and future, and can suppress the `ago`/`from now` suffix.

None of this is contact-domain, Saropa-format, icon, or search-syntax logic — it is generic date math and English relative-time phrasing.

### Overlap with existing library — IMPORTANT

The installed `saropa_dart_utils-1.4.1` already ships `relativeTimeString(DateTime, {clock})` in `lib/datetime/date_time_relative_utils.dart`. It produces a DIFFERENT output dialect: `"just now"` / `"in a moment"`, `"2 hours ago"` / `"in 3 days"`, `"yesterday"` / `"tomorrow"`, week/month/year coarse buckets with `in `/` ago` affixes. It deliberately uses fixed divisors (7/30/365) and has no descriptive/terse toggle, no `roundUp`, no suffix toggle.

So this is **partial-overlap**:

- **Already covered:** the general "relative time string" concept (`relativeTimeString`). Do NOT add a second formatter named `relativeTime` that conflicts — propose it as a distinct API (e.g. `relativeTimeDescriptive`) or fold the descriptive options into the existing function via new named params. The existing `relativeTimeString` output format must not change.
- **Net-new (additive):** the four calendar predicates `isTomorrow` / `isYesterday` / `isOlderThanToday` / `isOlderThanYesterday`, AND the descriptive-phrasing variants (`"a moment"`, `"about an hour"`, `"about a year"`), the terse mode, the `roundUp` flag, the suffix-suppression flag, and the date-based year algorithm.

The comparison extension already has `isToday`, `isDateAfterToday`, `isSameDateOnly`, `isSameDateOrAfter`/`Before` — but NOT `isYesterday`, `isTomorrow`, `isOlderThanToday`, or `isOlderThanYesterday`. Those four predicates are net-new.

## Source (from Saropa Contacts) — general-purpose members, verbatim (debug logging stripped)

All `debug()`/`DebugType`/`debugException` calls removed; the `import 'package:saropa/utils/_dev/debug.dart'` line is dropped. `try/catch` blocks that only existed to call `debugException` are collapsed (the library should let genuine errors surface, or replace with its own error policy). `isSameDateOnly`, `isNullOrEmpty`, and `pluralize` resolve from saropa_dart_utils.

```dart
const String nowTime = 'now';
const String timeSuffixPast = 'ago';
const String timeSuffixFuture = 'from now';

extension RelativeTimeUtils on DateTime {
  /// Checks if this [DateTime] is the calendar day after [now].
  bool isTomorrow({DateTime? now}) {
    final DateTime tomorrow = (now ?? DateTime.now()).add(const Duration(days: 1));

    return isSameDateOnly(tomorrow);
  }

  /// Checks if this [DateTime] is the calendar day before [now].
  bool isYesterday({DateTime? now}) {
    final DateTime yesterday = (now ?? DateTime.now()).subtract(const Duration(days: 1));

    return isSameDateOnly(yesterday);
  }

  /// Checks if this [DateTime] is before the start of today.
  bool isOlderThanToday({DateTime? now}) {
    final DateTime now_ = now ?? DateTime.now();

    // Start of today; any instant before it is "older than today".
    final DateTime startOfToday = DateTime(now_.year, now_.month, now_.day);

    return isBefore(startOfToday);
  }

  /// Checks if this [DateTime] is before the start of yesterday.
  bool isOlderThanYesterday({DateTime? now}) {
    final DateTime now_ = now ?? DateTime.now();

    final DateTime startOfToday = DateTime(now_.year, now_.month, now_.day);
    final DateTime startOfYesterday = startOfToday.subtract(const Duration(days: 1));

    return isBefore(startOfYesterday);
  }

  /// Relative-time phrase between this [DateTime] and [now]
  /// (defaults to [DateTime.now]).
  ///
  /// - [isDescriptive] - verbose ("a moment", "about an hour") vs terse
  ///   ("now", "~1h").
  /// - [isDescriptiveTimeSuffix] - append [timeSuffixPast] / [timeSuffixFuture].
  /// - [roundUp] - round the numeric unit instead of flooring.
  String? relativeTime({
    DateTime? now,
    bool isDescriptive = true,
    bool isDescriptiveTimeSuffix = true,
    bool roundUp = false,
  }) {
    if (this == now) {
      return nowTime;
    }

    // Cache once to prevent tick-overs mid-computation.
    now ??= DateTime.now();

    // Millisecond granularity (microsecond differences are intentionally ignored).
    int elapsed = millisecondsSinceEpoch - now.millisecondsSinceEpoch;

    // Use isBefore rather than `elapsed < 0` to stay correct at microsecond ties.
    final bool isBefore = this.isBefore(now);

    if (isBefore) {
      elapsed = elapsed.abs();
    }

    // For year-level spans use the date-based algorithm instead of
    // days/365.25 to avoid off-by-one errors near anniversary boundaries.
    final num days = elapsed / 1000 / 60 / 60 / 24;
    String? result;
    if (days >= 365) {
      result = _getYearMessage(
        fromDate: isBefore ? this : now,
        toDate: isBefore ? now : this,
        isDescriptive: isDescriptive,
      );
    }

    result ??= _getTimeMessage(elapsed: elapsed, isDescriptive: isDescriptive, roundUp: roundUp);
    if (result.isNullOrEmpty) {
      return null;
    }

    if (isDescriptiveTimeSuffix) {
      return '$result ${isBefore ? timeSuffixPast : timeSuffixFuture}';
    }

    return result;
  }
}

/// Whole years between two dates using calendar arithmetic:
/// subtract years, then back off one if the anniversary has not yet
/// occurred in [toDate]'s year. Returns null for sub-year spans so the
/// caller falls through to [_getTimeMessage].
String? _getYearMessage({
  required DateTime fromDate,
  required DateTime toDate,
  bool isDescriptive = true,
}) {
  int years = toDate.year - fromDate.year;

  if (toDate.month < fromDate.month ||
      (toDate.month == fromDate.month && toDate.day < fromDate.day)) {
    years--;
  }

  if (years < 1) {
    return null;
  }

  if (years == 1) {
    return isDescriptive ? 'about a year' : '~1y';
  }

  return '$years ${(isDescriptive ? 'year' : 'y').pluralize(years)}';
}

String? _getTimeMessage({required int elapsed, bool isDescriptive = true, bool roundUp = false}) {
  final num seconds = elapsed / 1000;
  if (seconds < 45) {
    return isDescriptive ? 'a moment' : 'now';
  }

  if (seconds < 90) {
    return isDescriptive ? 'a minute' : 'a min';
  }

  final num minutes = seconds / 60;

  if (minutes < 45) {
    final int displayMins = roundUp ? minutes.round() : minutes.floor();

    return '$displayMins ${(isDescriptive ? 'minute' : 'min').pluralize(displayMins)}';
  }

  if (minutes < 100) {
    return isDescriptive ? 'about an hour' : '~1h';
  }

  final num hours = minutes / 60;
  if (hours < 24) {
    final int displayHours = roundUp ? hours.round() : hours.floor();

    return '$displayHours ${(isDescriptive ? 'hour' : 'hr').pluralize(displayHours)}';
  }

  if (hours < 48) {
    return isDescriptive ? 'a day' : '~1d';
  }

  final num days = hours / 24;

  if (days < 30) {
    final int displayDays = roundUp ? days.round() : days.floor();

    return '$displayDays ${(isDescriptive ? 'day' : 'd').pluralize(displayDays)}';
  }

  if (days < 60) {
    return isDescriptive ? 'about a month' : '~1mo';
  }

  // Rough 30-day month average is acceptable for display.
  final num months = days / 30;
  if (days < 365) {
    final int displayMonths = roundUp ? months.round() : months.floor();

    return '$displayMonths ${(isDescriptive ? 'month' : 'mo').pluralize(displayMonths)}';
  }

  final num years = days / 365.25;

  if (years < 1.1) {
    return isDescriptive ? 'about a year' : '~1y';
  }

  final int displayYears = roundUp ? years.round() : years.floor();

  return '$displayYears ${(isDescriptive ? 'year' : 'y').pluralize(displayYears)}';
}
```

### Excluded members + why

- `import 'package:saropa/utils/_dev/debug.dart'` and every `debugException(error, stack)` call — app-specific Crashlytics/debug reporting; replace with the library's own error policy (prefer letting errors surface in pure utils).
- The commented-out `isBeforeFutureDays` line (dead code in source) — not exported.
- Nothing else in the file is proprietary; the whole extension is general-purpose date math + English phrasing.

## Test cases — existing tests verbatim (from `test/lib/utils/primitive/date_time/date_time_primitive_test.dart`)

```dart
group('RelativeTimeUtils', () {
  test('isYesterday returns true for yesterday', () {
    final DateTime now = DateTime(2024, 6, 15);
    final DateTime yesterday = DateTime(2024, 6, 14);
    expect(yesterday.isYesterday(now: now), isTrue);
  });

  test('isYesterday returns false for today', () {
    final DateTime now = DateTime(2024, 6, 15);

    // Ignoring because NOT self-comparison
    // ignore: avoid-passing-self-as-argument
    expect(now.isYesterday(now: now), isFalse);
  });

  test('isTomorrow returns true for tomorrow', () {
    final DateTime now = DateTime(2024, 6, 15);
    final DateTime tomorrow = DateTime(2024, 6, 16);
    expect(tomorrow.isTomorrow(now: now), isTrue);
  });

  test('isOlderThanToday returns true for past dates', () {
    final DateTime now = DateTime(2024, 6, 15, 12, 0);
    final DateTime yesterday = DateTime(2024, 6, 14);
    expect(yesterday.isOlderThanToday(now: now), isTrue);
  });

  test('isOlderThanToday returns false for today', () {
    final DateTime now = DateTime(2024, 6, 15, 12, 0);
    final DateTime today = DateTime(2024, 6, 15, 8, 0);
    expect(today.isOlderThanToday(now: now), isFalse);
  });

  test('relativeTime returns correct string for moments', () {
    final DateTime now = DateTime(2024, 6, 15, 12, 0, 0);
    final DateTime seconds = DateTime(2024, 6, 15, 11, 59, 30);
    final String? result = seconds.relativeTime(now: now);
    expect(result, contains('moment'));
  });

  test('relativeTime returns correct string for minutes', () {
    final DateTime now = DateTime(2024, 6, 15, 12, 0, 0);
    final DateTime minutes = DateTime(2024, 6, 15, 11, 55, 0);
    final String? result = minutes.relativeTime(now: now);
    expect(result, contains('minute'));
  });

  test('relativeTime returns correct string for hours', () {
    final DateTime now = DateTime(2024, 6, 15, 12, 0, 0);
    final DateTime hours = DateTime(2024, 6, 15, 9, 0, 0);
    final String? result = hours.relativeTime(now: now);
    expect(result, contains('hour'));
  });

  test('relativeTime returns correct string for days', () {
    final DateTime now = DateTime(2024, 6, 15);
    final DateTime days = DateTime(2024, 6, 10);
    final String? result = days.relativeTime(now: now);
    expect(result, contains('day'));
  });

  test('relativeTime returns correct string for years', () {
    final DateTime now = DateTime(2024, 6, 15);
    final DateTime years = DateTime(2020, 6, 15);
    final String? result = years.relativeTime(now: now);
    expect(result, contains('year'));
  });

  test('relativeTime handles future dates', () {
    final DateTime now = DateTime(2024, 6, 15);
    final DateTime future = DateTime(2024, 6, 20);
    final String? result = future.relativeTime(now: now);
    expect(result, contains('from now'));
  });
});
```

Note: `isOlderThanYesterday` has NO existing test — it must be added (see gaps).

## Bulletproofing gaps — concrete edge cases to add for massive coverage

**Predicates (`isTomorrow` / `isYesterday` / `isOlderThanToday` / `isOlderThanYesterday`):**

- **`isOlderThanYesterday` has zero tests** — add: returns `true` for two-days-ago, `false` for yesterday, `false` for the start-of-yesterday instant (boundary: `isBefore` is exclusive), `false` for today.
- **Boundary instants:** the exact start-of-today (`00:00:00.000`) — `isOlderThanToday` must be `false`; one microsecond before (`23:59:59.999999` previous day) must be `true`.
- **Time-of-day independence:** `isTomorrow`/`isYesterday` with `this` at `23:59` and `now` at `00:01` of the adjacent day — must still match (they compare date-only via `isSameDateOnly`).
- **Month/year roll-over:** `now = 2024-03-01`, `isYesterday` for `2024-02-29` (leap day); `now = 2024-01-01`, `isYesterday` for `2023-12-31`; `now = 2024-12-31`, `isTomorrow` for `2025-01-01`.
- **Leap-year boundaries:** Feb 28 / Feb 29 / Mar 1 in both leap (2024) and non-leap (2023, 2100) years.
- **UTC vs local:** `DateTime.utc(...)` receiver with a local `now` (and vice versa). The predicates use field comparison (`isSameDateOnly`) for tomorrow/yesterday but `isBefore` (instant comparison) for the older-than checks — document and test that the two families treat UTC/local differently; add cases proving the documented behavior.
- **DST transitions:** in a local zone with DST, the "spring forward" day is 23h and "fall back" is 25h. `add(Duration(days: 1))` adds exactly 24h, so on a DST day the resulting wall-clock date can be off. Add tests around a known DST boundary (e.g. US `2024-03-10`, `2024-11-03`) proving `isTomorrow`/`isYesterday` either hold or are documented as not-DST-safe.
- **`now` defaulting:** call each predicate with no `now` arg (exercises the `?? DateTime.now()` branch) on a constructed near-date and assert non-throwing / plausible result.

**`relativeTime`:**

- **Exact equality / zero elapsed:** `this == now` returns `'now'`; also `this != now` but same millisecond — verify the `<45s` "a moment" path vs the `==` short-circuit.
- **Past vs future symmetry:** same magnitude before and after `now` yields identical numeric body with `ago` vs `from now`.
- **Every bucket boundary** (test just-below and just-at each threshold): 45s, 90s, 45min, 100min, 24h, 48h, 30d, 60d, 365d, and the `years < 1.1` cusp. Off-by-one at these edges is the highest-risk area.
- **`roundUp` true vs false** at fractional units: e.g. 89.6 minutes → floor `1` vs round `2` (within the `<100min` "about an hour" band — confirm roundUp doesn't leak past the band); 2.6 days, 1.6 hours.
- **Plural/singular:** 1 minute vs 2 minutes, 1 hour vs 2 hours, 1 day vs 2 days, 1 month vs 2 months, exactly-1-year → `'about a year'` (not `'1 year'`), 2 years → `'2 years'`.
- **Terse mode (`isDescriptive: false`):** assert exact terse tokens `now`, `a min`, `N min`, `~1h`, `N hr`, `~1d`, `N d`, `~1mo`, `N mo`, `~1y`, `N y`.
- **Suffix toggle:** `isDescriptiveTimeSuffix: false` strips `ago`/`from now`; combined with terse mode.
- **Year algorithm correctness near anniversaries:** birthday not yet reached this year — `from 2000-12-31` to `now 2024-06-15` should be `23 years`, not `24`; exactly-on-anniversary `from 2000-06-15` to `2024-06-15` → `24 years`; one day before anniversary → `23 years`. This is the precise off-by-one the date-based algorithm exists to fix.
- **Leap-day anniversary:** `from 2020-02-29` to `now 2024-02-28` (one day before) vs `2024-02-29` vs `2024-03-01`.
- **Extremes:** `DateTime` at epoch `0`, far-future (`9999-12-31`), and far-past; very large `elapsed` (does the `num` division stay finite and produce sane year counts?).
- **UTC vs local receiver:** `relativeTime` mixes `millisecondsSinceEpoch` (absolute) with `isBefore` (absolute) — generally zone-safe; add a UTC-receiver + local-`now` test to lock it in.
- **Null return contract:** confirm there is a documented input that returns `null` (after removing the debug try/catch, the only `null` paths are the year-message fallthrough and `isNullOrEmpty`). Add a test asserting `null` is unreachable for ordinary inputs, or adjust the contract to non-nullable if it truly cannot return null post-refactor.
- **DST in the day band:** a span crossing a DST boundary where wall-clock hours ≠ 24×days — verify the millisecond-based math (not wall-clock) keeps the bucket correct.
- **No emoji/unicode/empty/NaN/infinity inputs apply** — inputs are `DateTime` only, no strings or doubles from the user; NaN/infinity cannot enter via the public API, but a test feeding a `Duration`-derived extreme that would make internal `num` divisions non-finite should confirm no `Infinity`/`NaN` leaks into the output string.
```
