# SPEC: DateFormatting (getUtcOffset, dateDisplay, makeDisplayDate, makeDisplayTime, utcTimeDisplay, fullDateDisplay, formatByLocale, toDateFormat, UtcTimeDisplayEnum) — for inclusion

**Status:** Proposed (from Saropa Contacts) — **partial-overlap**, intl-based variant
**Proposed location:** `lib/datetime/date_time_intl_display_extensions.dart` (NEW intl-coupled module, kept separate from the existing no-intl presets)
**Portability:** Dart + **external pkg `intl`** (`package:intl/intl.dart`, `DateFormat`). The current library `lib/datetime/` is deliberately **intl-free** (see `date_format_preset_utils.dart` header: "deliberately avoids the heavyweight intl dependency"). These extensions REQUIRE intl for locale-correct skeleton ordering / clock detection. Inclusion therefore means either (a) a separate opt-in module that pulls intl, or (b) declining and keeping the no-intl presets. `getUtcOffset` alone is pure Dart (no intl).

## Purpose — what it does + why it is general-purpose (not proprietary)

A `DateTime` extension that produces human-readable, **locale-correct** date/time strings via intl skeletons (`yMMMd`, `yMMMMd`, `MMMEd`, `jm`, `jms`, `Hm`, `Hms`, …) instead of hardcoded English-ordered patterns. The general value over the library's existing manual presets is that intl skeletons reorder components per locale (en_US "Jan 15, 1945" / fr_FR "15 janv. 1945" / ja_JP "1945年1月15日" — escaped: `1945年1月15日`) and detect the locale's clock convention (12h AM/PM vs 24h) automatically. None of the formatting logic is contact-domain specific; it operates on any `DateTime`.

`getUtcOffset` formats `timeZoneOffset` as `UTC+H:MM` / `UTC-H` / `UTC±0` — a general timezone-offset display.

### Excluded members + why

- **`toDateTimeEmojiDisplay`** — depends on `getSimpleRelativeDay()` / `SimpleRelativeDay` (app-internal relative-day module). Relative-day bucketing already exists in the library (`relative_date_bucket_utils.dart`); excluded to avoid app coupling.
- **`dateTimeDisplay` `showTodayWord` / `appendDayNightEmoji` paths** — `todayWord` is a hardcoded English literal (`'Today'`) and the emoji path calls app-internal `TimeEmojiUtils.getEmojiDayOrNight`. The library already has `time_emoji_utils.dart`; the app helper and the English literal are excluded. The core `dateTimeDisplay` join logic CAN be ported if its emoji/today branches are dropped.
- **`makeDisplayTime` `showSeconds` branch** — calls `l10n.durationSecondsShort(second)` (AppLocalizations, plural-aware). EXCLUDED per scope (no l10n). The library's `duration_format_utils.dart` already supplies unit suffixes; a ported version would take an injected suffix or use the existing duration formatter.
- **`debug()` / `debugException()` / `DebugType.Primitive.isDebug` logging** — app instrumentation; stripped from all quoted source below.
- **`LocaleUtils.getLocaleStringFromContext()` / `getLocaleFromContext(context)` / `formatByLocale(context:)` BuildContext path** — Flutter `BuildContext` + app locale service. The general port takes an explicit `String? locale` parameter instead of pulling locale from a widget context.
- **`makeNonBreaking()` / `joinNotNullOrEmpty()` / `isNullOrEmpty` / `ordinal()`** — string extensions from app/library utils. `ordinal()` and join/null-empty helpers already exist in this library (`string/`, `iterable/`); `makeNonBreaking` is an app extension (swaps ASCII space/hyphen for U+00A0/non-breaking forms) and would need porting or replacing with an explicit ` ` join.

### Overlap with installed library (1.4.1)

- `lib/datetime/date_format_preset_utils.dart` — `formatDateShort` (`yyyy-MM-dd`), `formatDateMedium` (`Jun 10, 2026`), `formatDateLong` (`Wednesday, June 10, 2026`) with **injectable** `DateFormatNames`. **Library already has fixed-layout presets**; this util adds **intl-driven per-locale component REORDERING and clock detection**, which the injectable-names design cannot do (it formats in a fixed layout and only swaps names).
- `lib/datetime/date_time_timezone_extensions.dart` — `timeZoneOffsetString` returns `+01:00` / `-05:30` (ISO-style, always `±HH:MM`). **Library already has the ISO offset string**; `getUtcOffset` adds the **`UTC`-prefixed, minute-eliding, `±` for zero** variant (`UTC+5`, `UTC±0`, `UTC+5:30`). NOTE the formats differ — propose `getUtcOffset` as a sibling, not a replacement.
- `lib/datetime/duration_format_utils.dart` — `formatDuration` (compact `2h 30m`). Adjacent only; not a direct overlap.

Net assessment: **partial-overlap**. Date/duration/offset display exist in fixed/manual form; the net-new contribution is the **intl-locale-correct** rendering path (skeleton reordering + 12h/24h auto-detection). Recommend a SEPARATE intl-gated module so the core package stays intl-free.

## Source (from Saropa Contacts) — general-purpose members, verbatim (debug logging + l10n + app-context stripped)

```dart
import 'package:intl/intl.dart';

enum UtcTimeDisplayEnum {
  /// Displays hours, minutes, seconds, and AM/PM (e.g., 10:30:45 PM)
  twelveHourWithSecondsAMPM,

  /// Displays hours, minutes, and AM/PM (e.g., 10:30 PM)
  twelveHourAMPM,

  /// Displays hours, minutes, and seconds (e.g., 22:30:45)
  twentyFourHourWithSeconds,

  /// Displays hours and minutes (e.g., 22:30)
  twentyFourHour,

  /// Displays hours and minutes without AM/PM (e.g., 10:30)
  twelveHour,

  /// Displays only AM/PM (e.g., PM)
  amPmOnly,
}

/// Locale-correct DateTime display. [locale] is an intl locale string
/// (e.g. 'en_US', 'fr_FR'); null lets intl use its default.
extension DateFormatting on DateTime {
  /// UTC offset for this DateTime as "UTC+H:MM" / "UTC-H" / "UTC±0".
  /// Pure Dart (no intl). Returns null on failure.
  String? getUtcOffset({bool verbose = false}) {
    try {
      final Duration offset = timeZoneOffset;
      if (offset.inSeconds == 0) {
        // verbose: 'UTC±00:00', otherwise 'UTC±0'
        return verbose ? 'UTC±00:00' : 'UTC±0';
      }
      final String offsetSign = offset.isNegative ? '-' : '+';
      final int offsetHours = offset.inHours.abs();
      final int offsetMinutes = offset.inMinutes.remainder(60).abs();
      // Only display minutes when non-zero.
      if (offsetMinutes > 0) {
        return 'UTC$offsetSign$offsetHours:${offsetMinutes.toString().padLeft(2, '0')}';
      } else {
        return 'UTC$offsetSign$offsetHours';
      }
    } on Object {
      return null;
    }
  }

  /// - [format]                   E.g. 'HH:mm:ss'
  /// - [showLogTimeMilliseconds]  Appends '.0137'
  String toDateFormat(
    String format, {
    String? locale,
    bool showLogTimeMilliseconds = false,
  }) {
    try {
      return DateFormat(format, locale).format(this) +
          (showLogTimeMilliseconds
              ? '.${millisecond.toString().padLeft(4, '0')}'
              : '');
    } on Object {
      return '';
    }
  }

  /// Get a string similar to "Jan 15, 1945", or "Jan 15th, 1945" with
  /// [showDayOrdinal]. When [showCurrentYear] is false, omits year for
  /// current-year dates.
  ///
  /// Named skeletons (yMMMd / MMMMd / ...) reorder per locale; raw patterns
  /// do not. 'MMMM' selects the full month name, anything else abbreviated.
  /// Ordinals ("15th") are English-only, so showDayOrdinal keeps fixed
  /// English month-day order.
  String dateDisplay({
    String monthFormat = 'MMM',
    bool showDayOrdinal = false,
    bool showCurrentYear = true,
    String? locale,
    DateTime? now,
  }) {
    now ??= DateTime.now();
    final bool currentYear = year == now.year;
    final bool showYear = showCurrentYear || !currentYear;

    if (showDayOrdinal) {
      final String monthDisplay =
          DateFormat(monthFormat, locale).format(DateTime(now.year, month));
      // ordinal() supplies English "1st/2nd/15th" — library string util.
      return showYear
          ? '$monthDisplay ${_ordinal(day)}, $year'
          : '$monthDisplay ${_ordinal(day)}';
    }

    final bool fullMonth = monthFormat == 'MMMM';
    final DateFormat formatter = showYear
        ? (fullMonth ? DateFormat.yMMMMd(locale) : DateFormat.yMMMd(locale))
        : (fullMonth ? DateFormat.MMMMd(locale) : DateFormat.MMMd(locale));
    return formatter.format(this);
  }

  /// Returns 'EEE, MMM d, yyyy' = 'Thu, Jul 21, 2020' (locale-ordered).
  String? makeDisplayDate({
    bool showYear = true,
    bool showCurrentYear = false,
    bool showWeekday = true,
    String? locale,
    DateTime? now,
  }) {
    try {
      now ??= DateTime.now();
      final bool currentYear = year == now.year;
      showYear &= (showCurrentYear || !currentYear) && year > 0;

      final String displayDate;
      if (showWeekday) {
        displayDate = showYear
            ? DateFormat.yMMMEd(locale).format(this)
            : DateFormat.MMMEd(locale).format(this);
      } else {
        displayDate = showYear
            ? DateFormat.yMMMd(locale).format(this)
            : DateFormat.MMMd(locale).format(this);
      }
      return displayDate;
    } on Object {
      return null;
    }
  }

  /// Returns 'HH:mm' / 'h:mm a' (locale clock), or hour-only when minutes are
  /// zero. Defaults to the locale's clock convention (12h AM/PM vs 24h),
  /// detected from intl's `jm` skeleton; override with [hour24] / [showAMPM].
  /// The clock and its AM/PM marker are joined with a non-breaking space
  /// (U+00A0) so a bare time never wraps across two lines.
  String? makeDisplayTime({
    bool showSeconds = false,
    bool? showAMPM,
    bool? hour24,
    bool omitZeroMinutes = true,
    String? locale,
  }) {
    try {
      // 'H' present in the jm pattern => this locale uses a 24h clock.
      final bool localeUses24Hour =
          DateFormat.jm(locale).pattern?.contains('H') ?? false;
      final bool use24 = hour24 ?? localeUses24Hour;
      // AM/PM is meaningless on a 24h clock; suppress whenever 24h is in effect.
      final bool useAMPM = (showAMPM ?? !localeUses24Hour) && !use24;

      // Omit :00 when minutes are zero for cleaner display.
      final bool hasMinutes = minute != 0;
      String pattern;
      if (omitZeroMinutes && !hasMinutes && !showSeconds) {
        pattern = use24 ? 'HH' : 'h';
      } else {
        pattern = use24 ? 'HH:mm' : 'h:mm';
      }
      if (useAMPM) {
        pattern += ' a';
      }

      // ", N secs" suffix is supplied by the caller (the app version uses a
      // plural-aware l10n key; excluded here). Append outside the clock so the
      // suffix keeps a normal, breakable space.
      final String displaySeconds =
          showSeconds ? ', ${DateFormat('ss', locale).format(this)} s' : '';

      // Non-breaking space inside the clock so "8:31 PM" never wraps. Only the
      // clock portion is non-broken; any ", N secs" suffix stays breakable.
      final String clock = DateFormat(pattern, locale)
          .format(this)
          .replaceAll(' ', ' ');
      return clock + displaySeconds;
    } on Object {
      return null;
    }
  }

  /// Fixed-form clock display via [UtcTimeDisplayEnum]. The result has its
  /// ASCII spaces converted to non-breaking so the clock never wraps.
  String utcTimeDisplay(
    UtcTimeDisplayEnum type, {
    String? locale,
  }) {
    final String formatted = switch (type) {
      UtcTimeDisplayEnum.twelveHourWithSecondsAMPM =>
        DateFormat.jms(locale).format(this),
      UtcTimeDisplayEnum.twelveHourAMPM => DateFormat.jm(locale).format(this),
      UtcTimeDisplayEnum.twentyFourHourWithSeconds =>
        DateFormat.Hms(locale).format(this),
      UtcTimeDisplayEnum.twentyFourHour => DateFormat.Hm(locale).format(this),
      UtcTimeDisplayEnum.twelveHour => DateFormat('h:mm', locale).format(this),
      UtcTimeDisplayEnum.amPmOnly => DateFormat('a', locale).format(this),
    };
    return formatted.replaceAll(' ', ' ');
  }

  /// Locale-ordered full month name, day, year:
  /// "January 15, 1945" (en_US), "15 janvier 1945" (fr_FR),
  /// "1945年1月15日" (ja_JP). Uses the yMMMMd skeleton so the
  /// component order follows the chosen language (a literal 'd MMMM yyyy'
  /// pattern would lock English order).
  String fullDateDisplay({String? locale}) {
    try {
      return DateFormat.yMMMMd(locale).format(this);
    } on Object {
      return '';
    }
  }

  /// Locale short date: en_US '08/16/2023', en_GB/fr_FR '16/08/2023'.
  /// [ddMMyyFormat] forces 'dd MMM yy' instead of the yMd skeleton.
  String? formatByLocale({String? locale, bool ddMMyyFormat = false}) {
    try {
      return ddMMyyFormat
          ? DateFormat('dd MMM yy', locale).format(this)
          : DateFormat.yMd(locale).format(this);
    } on Object {
      return null;
    }
  }

  // English ordinal helper — the library already exposes an `ordinal()` int
  // extension in lib/int/; reuse it instead of this inline placeholder.
  String _ordinal(int n) {
    if (n % 100 >= 11 && n % 100 <= 13) return '${n}th';
    return switch (n % 10) {
      1 => '${n}st',
      2 => '${n}nd',
      3 => '${n}rd',
      _ => '${n}th',
    };
  }
}
```

## Test cases — existing tests verbatim (from `date_formatting_locale_test.dart`)

The app's tests run against the en_US fallback locale, exercising the intl skeleton ordering and the 12h/24h clock detection. Non-ASCII expectations use ` ` escapes for the non-breaking space.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  setUpAll(() async {
    // Required for non-en locales — date_symbol_data_local must be loaded once
    // per process before any DateFormat with a non-en locale runs.
    await initializeDateFormatting();
  });

  group('fullDateDisplay locale ordering', () {
    final DateTime jan15_1945 = DateTime(1945, 1, 15);

    test('en_US uses month-first ordering with full month name', () {
      expect(jan15_1945.fullDateDisplay(locale: 'en_US'),
          equals('January 15, 1945'));
    });
  });

  group('MMMMd skeleton locale ordering', () {
    final DateTime may10 = DateTime(2026, 5, 10);

    test('en_US produces month-first ordering', () {
      expect(DateFormat.MMMMd('en_US').format(may10), equals('May 10'));
    });
    test('fr_FR produces day-first ordering', () {
      expect(DateFormat.MMMMd('fr_FR').format(may10), equals('10 mai'));
    });
    test('de_DE produces day-dot-space-month ordering', () {
      expect(DateFormat.MMMMd('de_DE').format(may10), equals('10. Mai'));
    });
  });

  group('dateDisplay locale ordering', () {
    final DateTime jan15_1945 = DateTime(1945, 1, 15);

    test('en_US default uses abbreviated month, month-first, with year', () {
      expect(jan15_1945.dateDisplay(locale: 'en_US'), equals('Jan 15, 1945'));
    });
    test('monthFormat MMMM selects the full month name', () {
      expect(jan15_1945.dateDisplay(locale: 'en_US', monthFormat: 'MMMM'),
          equals('January 15, 1945'));
    });
    test('showDayOrdinal keeps the fixed English ordinal order', () {
      expect(jan15_1945.dateDisplay(locale: 'en_US', showDayOrdinal: true),
          equals('Jan 15th, 1945'));
    });
    test('skeleton order is month-first en_US but day-first fr_FR', () {
      expect(DateFormat.yMMMd('en_US').format(jan15_1945), startsWith('Jan'));
      expect(DateFormat.yMMMd('fr_FR').format(jan15_1945), startsWith('15'));
    });
  });

  group('makeDisplayTime locale clock convention', () {
    final DateTime at1530 = DateTime(2026, 1, 15, 15, 30);
    final DateTime at1500 = DateTime(2026, 1, 15, 15);

    test('en_US default renders 12h AM/PM', () {
      // clock joined to AM/PM with a non-breaking space U+00A0
      expect(at1530.makeDisplayTime(locale: 'en_US'), equals('3:30 PM'));
    });
    test('en_US default omits :00 minutes on the hour', () {
      expect(at1500.makeDisplayTime(locale: 'en_US'), equals('3 PM'));
    });
    test('explicit hour24 + showAMPM:false forces a 24h clock', () {
      expect(at1530.makeDisplayTime(hour24: true, showAMPM: false),
          equals('15:30'));
    });
    test('jm pattern reveals 12h en_US but 24h fr_FR/de_DE/ja_JP', () {
      expect(DateFormat.jm('en_US').pattern, isNot(contains('H')));
      expect(DateFormat.jm('en_GB').pattern, contains('H'));
      expect(DateFormat.jm('fr_FR').pattern, contains('H'));
      expect(DateFormat.jm('de_DE').pattern, contains('H'));
      expect(DateFormat.jm('ja_JP').pattern, contains('H'));
    });
  });

  group('makeDisplayTime non-breaking clock', () {
    test('joins the clock and AM/PM with a non-breaking space', () {
      final DateTime at2031 = DateTime(2026, 1, 15, 20, 31);
      expect(at2031.makeDisplayTime(locale: 'en_US'), equals('8:31 PM'));
      // No ASCII space survives in the clock portion.
      expect(at2031.makeDisplayTime(locale: 'en_US')!.contains(' '), isFalse);
    });
  });

  group('utcTimeDisplay non-breaking clock', () {
    final DateTime at2031 = DateTime(2026, 1, 15, 20, 31);

    test('twelveHourAMPM clock contains no ASCII space', () {
      final String formatted =
          at2031.utcTimeDisplay(UtcTimeDisplayEnum.twelveHourAMPM, locale: 'en_US');
      expect(formatted.contains(' '), isFalse);
      expect(formatted, startsWith('8:31'));
      expect(formatted, endsWith('PM'));
    });
    test('twentyFourHour returned unchanged (no space to break)', () {
      expect(
          at2031.utcTimeDisplay(UtcTimeDisplayEnum.twentyFourHour, locale: 'en_US'),
          equals('20:31'));
    });
  });
}
```

No existing test covers `getUtcOffset`, `toDateFormat`, `formatByLocale`, or `makeDisplayDate` directly — see proposed cases below.

## Bulletproofing gaps — concrete edge cases to add for massive coverage

**getUtcOffset (pure Dart, no intl — easiest to make bulletproof):**
- Zero offset → `'UTC±0'`; verbose → `'UTC±00:00'` (assert the `±` plus-minus sign explicitly, not a flattened ASCII `+/-`).
- Positive whole hour (UTC+5) → `'UTC+5'` (no minutes).
- Negative whole hour (UTC-8) → `'UTC-8'`.
- Half-hour offset (UTC+5:30 India) → `'UTC+5:30'`; negative half (UTC-3:30 Newfoundland) → `'UTC-3:30'`.
- 45-minute offset (UTC+5:45 Nepal, UTC+12:45 Chatham) → minute padding `:45`.
- Extreme offsets: UTC+14 (Kiribati), UTC-12 → no overflow.
- Note: `timeZoneOffset` is environment-dependent — to make this testable, the ported version should accept an explicit `Duration` (or a `DateTime` whose offset is fixed) rather than reading the host TZ. Add a `Duration`-input overload for deterministic tests.

**Date display (intl, leap/boundary):**
- Leap day Feb 29 (2024) formats without error; non-leap Feb 28.
- Year 1 / year 0 / negative-ish years (`DateTime(0)`, `DateTime(1)`) — `makeDisplayDate` guards `year > 0`; assert year suppressed when `year <= 0`.
- Year 9999 (max-ish) and very large years render.
- Month/day boundaries: Jan 1, Dec 31.
- `showCurrentYear: false` with a date IN the current year (inject `now`) omits the year; with a date in a DIFFERENT year keeps it.
- `dateDisplay` ordinals: 1st, 2nd, 3rd, 4th, 11th, 12th, 13th (the -teen exception), 21st, 22nd, 23rd, 31st — the `% 100 in 11..13` carve-out is the classic bug.

**Time display (intl, clock + omit-minutes):**
- Midnight `00:00` → 12h `'12 AM'`, 24h `'00'`/`'00:00'`.
- Noon `12:00` → `'12 PM'`.
- `omitZeroMinutes` false at `:00` → keeps `'12:00 AM'`.
- Single-digit minute (`3:05`) → zero-padded `'3:05 PM'`.
- Seconds suffix at `:00` seconds, `:01` (singular), `:59`.
- Locale sweep: assert en_US (12h), en_GB / fr_FR / de_DE / ja_JP (24h) via the `jm` pattern signal AND the rendered string; requires `initializeDateFormatting()` in `setUpAll`.
- Non-breaking invariant: rendered clock contains NO `0x20` (ASCII space); assert `.contains(' ') == false` and also that ` ` / ` ` (CLDR narrow no-break space) IS present for 12h.

**Robustness / failure modes:**
- Invalid format pattern passed to `toDateFormat` → returns `''` (the try/catch contract), never throws.
- Unknown / malformed locale string (e.g. `'xx_YY'`, empty `''`) — intl throws if `date_symbol_data_local` lacks it; the port must catch and degrade, and the test must assert no throw.
- `null` locale → intl default; deterministic only after `initializeDateFormatting`.
- UTC vs local `DateTime` input: a `DateTime.utc(...)` and a local `DateTime` with the same wall-clock fields format identically (formatting reads the wall-clock fields, not the offset) — pin this so callers aren't surprised.
- DST boundary instants (spring-forward 02:30 that doesn't exist, fall-back 01:30 that occurs twice) — `DateTime` normalizes these; assert formatting still produces a valid string and does not throw.
- Non-ASCII output integrity: fr_FR `'15 janv. 1945'` and ja_JP output (`'1945年1月15日'`) must round-trip through the test without flattening — assert via `codeUnits` / explicit `\u` escapes, never a pasted glyph.
