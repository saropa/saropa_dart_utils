# SPEC: HebrewDateConverter (Gregorian → Hebrew calendar) — for inclusion

**Status:** Proposed (from Saropa Contacts)
**Proposed location:** lib/datetime/hebrew_date_converter.dart
**Portability:** Pure Dart. Only external dependency is `package:meta`
(`@useResult`) — already a transitive/dev dep in this library. No Flutter, no
`intl`, no I/O, no platform channels. All methods are static; the class is
`abstract final` (non-instantiable). Hebrew script appears only in the
`monthNamesHebrew` / numeral output strings — pure data, no rendering.

## Overlap with installed library (saropa_dart_utils 1.4.1)

Checked `lib/datetime/` in `D:/tools/Pub/Cache/hosted/pub.dev/saropa_dart_utils-1.4.1/lib`.
It carries Gregorian-only date/time utilities (arithmetic, bounds, calendar,
fiscal, business days, timezone, recurrence/rrule, relative buckets, etc.).
A repo-wide grep for `Hebrew` / `hebrew` over the installed `lib/` returned
**no matches**. There is no Hebrew, Jewish, lunisolar, or any non-Gregorian
calendar converter present.

**Result: NET-NEW.** No symbol overlaps; this adds a whole calendar system the
library does not currently model.

## Purpose — what it does + why it is general-purpose

`HebrewDateConverter` converts a Gregorian `DateTime` to a Hebrew-calendar date
and formats it. The Hebrew calendar is a lunisolar calendar (12 or 13 months;
years counted from the traditional date of Creation, 3761 BCE). The
implementation is the fixed arithmetic algorithm from "Calendrical
Calculations" (Reingold & Dershowitz) via a Julian-Day-Number bridge — no
network lookup, no astronomical observation, deterministic for any
`DateTime`.

General-purpose, not proprietary:
- Operates purely on `DateTime` ints (year/month/day) and returns a plain
  record `({int year, int month, int day})` plus formatting strings. No contact
  domain, no app models, no l10n catalog, no Saropa-specific formats.
- Calendar conversion + month-name + gematria (Hebrew-numeral) formatting are
  the same operations any calendar library exposes.
- The only consumer-coupling in the source was incidental (it is referenced by
  a Jewish-holidays test fixture in the app); the converter itself knows nothing
  about that.

### Excluded members (and why)

None excluded by content — the entire class is general-purpose calendar math.
The private helpers (`_elapsedMonths`, `_elapsedDays`, `_isLongCheshvan`,
`_isShortKislev`, `_gregorianToJulianDay`, `_hebrewNewYearJd`,
`_julianDayToHebrew`, `_numberToHebrewNumerals`, and the `_hebrewEpochJd` /
`_hebrewNumerals` constants) are kept verbatim because the public API depends on
them, but they remain private. There is **no** debug/`DebugType`/Crashlytics
logging, no `AppLocalizations`/`l10n` call, no Font Awesome icon, and no app
search-query syntax in this file — nothing had to be stripped. The
`// cspell:disable` pragma is retained (it only silences the spell-checker over
the Hebrew transliterations and is harmless to keep).

Public surface proposed for inclusion:

| Member | Kind | Returns |
|---|---|---|
| `monthNames` | `static const List<String>` | English transliterations |
| `monthNamesHebrew` | `static const List<String>` | Hebrew-script names |
| `isHebrewLeapYear(int)` | static | `bool` |
| `monthsInHebrewYear(int)` | static | `int` (12 or 13) |
| `daysInHebrewYear(int)` | static | `int` (353–355 / 383–385) |
| `daysInHebrewMonth(int, int)` | static | `int` (29 or 30) |
| `fromGregorian(DateTime)` | static | `({int year, int month, int day})` |
| `getMonthName(int, int, {bool useHebrew})` | static | `String` |
| `formatDayHebrew(int)` | static | `String` (gematria day) |
| `formatYearHebrew(int)` | static | `String` (gematria year, no thousands) |
| `format(DateTime, {bool useHebrew})` | static | `String` |
| `formatDayMonth(DateTime, {bool useHebrew})` | static | `String` |

## Source (from Saropa Contacts) — verbatim, Hebrew as `\u` escapes

> Hebrew-script string literals are shown as Dart `\u`-escapes to survive
> transit. They compile identically to the original glyphs. No debug logging
> was present to strip.

```dart
import 'package:meta/meta.dart' show useResult;

// cspell:disable
/// Converts Gregorian dates to Hebrew calendar dates.
///
/// The Hebrew calendar is a lunisolar calendar with 12 or 13 months.
/// Years are counted from the traditional date of Creation (3761 BCE).
///
/// This implementation uses the fixed arithmetic Hebrew calendar based on
/// the algorithms from "Calendrical Calculations" by Reingold and Dershowitz.
abstract final class HebrewDateConverter {
  /// Hebrew month names in English transliteration.
  static const List<String> monthNames = <String>[
    'Tishrei', // 1
    'Cheshvan', // 2
    'Kislev', // 3
    'Tevet', // 4
    'Shevat', // 5
    'Adar', // 6 (or Adar I in leap year)
    'Adar II', // 7 (only in leap year, otherwise skipped)
    'Nisan', // 7 or 8
    'Iyar', // 8 or 9
    'Sivan', // 9 or 10
    'Tammuz', // 10 or 11
    'Av', // 11 or 12
    'Elul', // 12 or 13
  ];

  /// Hebrew month names in Hebrew script.
  static const List<String> monthNamesHebrew = <String>[
    'תִּשְׁרֵי', // Tishrei
    'חֶשְׁוָן', // Cheshvan
    'כִּסְלֵו', // Kislev
    'טֵבֵת', // Tevet
    'שְׁבָט', // Shevat
    'אֲדָר', // Adar (or Adar I)
    'אֲדָר ב׳', // Adar II
    'נִיסָן', // Nisan
    'אִיָּר', // Iyar
    'סִיוָן', // Sivan
    'תַּמּוּז', // Tammuz
    'אָב', // Av
    'אֱלוּל', // Elul
  ];

  /// Hebrew numerals for numbers 1-30 (used for days).
  static const List<String> _hebrewNumerals = <String>[
    '', // 0 placeholder
    'א׳', 'ב׳', 'ג׳', 'ד׳', 'ה׳', 'ו׳', 'ז׳', 'ח׳', 'ט׳', // 1-9
    'י׳', 'י״א', 'י״ב', 'י״ג', 'י״ד', 'ט״ו', 'ט״ז', 'י״ז', 'י״ח', 'י״ט', // 10-19
    'כ׳', 'כ״א', 'כ״ב', 'כ״ג', 'כ״ד', 'כ״ה', 'כ״ו', 'כ״ז', 'כ״ח', 'כ״ט', // 20-29
    'ל׳', // 30
  ];

  /// Returns true if the given Hebrew year is a leap year.
  ///
  /// A Hebrew leap year has 13 months instead of 12.
  /// Leap years occur in years 3, 6, 8, 11, 14, 17, and 19 of a 19-year cycle.
  static bool isHebrewLeapYear(int hebrewYear) {
    return (hebrewYear * 7 + 1) % 19 < 7;
  }

  /// Returns the number of months in a Hebrew year.
  static int monthsInHebrewYear(int hebrewYear) {
    return isHebrewLeapYear(hebrewYear) ? 13 : 12;
  }

  /// Computes the number of elapsed months up to the given Hebrew year.
  @useResult
  static int _elapsedMonths(int hebrewYear) {
    final int y = hebrewYear - 1;

    return (235 * y + 1) ~/ 19;
  }

  /// Computes the number of days elapsed from the epoch (1 Tishrei year 1)
  /// to the start of the given Hebrew year.
  @useResult
  static int _elapsedDays(int hebrewYear) {
    final int m = _elapsedMonths(hebrewYear);
    final int parts = 204 + 793 * (m % 1080);
    final int hours = 5 + 12 * m + 793 * (m ~/ 1080) + parts ~/ 1080;
    final int day = 1 + 29 * m + hours ~/ 24;

    final int remainder = hours % 24;
    final int partsMod = parts % 1080;

    // Calculate day of week (0 = Sunday)
    final int dow = day % 7;

    // Apply postponement rules
    if (remainder >= 18 ||
        (dow == 2 && remainder >= 9 && partsMod >= 204 && !isHebrewLeapYear(hebrewYear)) ||
        (dow == 1 && remainder >= 15 && partsMod >= 589 && isHebrewLeapYear(hebrewYear - 1))) {
      // Postpone by one day
      final int newDow = (dow + 1) % 7;
      if (newDow == 0 || newDow == 3 || newDow == 5) {
        return day + 2;
      }
      return day + 1;
    }

    if (dow == 0 || dow == 3 || dow == 5) {
      return day + 1;
    }

    return day;
  }

  /// Returns the number of days in a Hebrew year.
  static int daysInHebrewYear(int hebrewYear) {
    return _elapsedDays(hebrewYear + 1) - _elapsedDays(hebrewYear);
  }

  /// Returns true if Cheshvan is long (30 days) in the given year.
  @useResult
  static bool _isLongCheshvan(int hebrewYear) {
    return daysInHebrewYear(hebrewYear) % 10 == 5;
  }

  /// Returns true if Kislev is short (29 days) in the given year.
  @useResult
  static bool _isShortKislev(int hebrewYear) {
    return daysInHebrewYear(hebrewYear) % 10 == 3;
  }

  /// Returns the number of days in a Hebrew month.
  ///
  /// Month indices are 1-based:
  /// 1=Tishrei, 2=Cheshvan, 3=Kislev, 4=Tevet, 5=Shevat, 6=Adar (or Adar I),
  /// 7=Adar II (leap years only) or Nisan, etc.
  static int daysInHebrewMonth(int hebrewYear, int month) {
    final bool isLeap = isHebrewLeapYear(hebrewYear);

    // Map month to the canonical month number (accounting for leap years)
    int canonicalMonth;
    if (isLeap) {
      canonicalMonth = month;
    } else {
      // In non-leap years, month 7+ maps to canonical 8+ (skip Adar II)
      canonicalMonth = month >= 7 ? month + 1 : month;
    }

    switch (canonicalMonth) {
      case 1: // Tishrei
        return 30;
      case 2: // Cheshvan
        return _isLongCheshvan(hebrewYear) ? 30 : 29;
      case 3: // Kislev
        return _isShortKislev(hebrewYear) ? 29 : 30;
      case 4: // Tevet
        return 29;
      case 5: // Shevat
        return 30;
      case 6: // Adar (or Adar I in leap year)
        return isLeap ? 30 : 29;
      case 7: // Adar II (leap year only)
        return 29;
      case 8: // Nisan
        return 30;
      case 9: // Iyar
        return 29;
      case 10: // Sivan
        return 30;
      case 11: // Tammuz
        return 29;
      case 12: // Av
        return 30;
      case 13: // Elul
        return 29;
      default:
        return 0;
    }
  }

  /// The Hebrew epoch as a Julian Day Number.
  /// 1 Tishrei year 1 = Julian Day 347997
  static const int _hebrewEpochJd = 347997;

  /// Converts a Gregorian date to a Julian Day Number.
  @useResult
  static int _gregorianToJulianDay(DateTime date) {
    final int year = date.year;
    final int month = date.month;
    final int day = date.day;

    final int a = (14 - month) ~/ 12;
    final int y = year + 4800 - a;
    final int m = month + 12 * a - 3;

    return day + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;
  }

  /// Returns the Julian Day Number of 1 Tishrei of the given Hebrew year.
  @useResult
  static int _hebrewNewYearJd(int hebrewYear) {
    return _hebrewEpochJd + _elapsedDays(hebrewYear);
  }

  /// Converts a Julian Day Number to a Hebrew date.
  @useResult
  static ({int year, int month, int day}) _julianDayToHebrew(int jd) {
    // Approximate year
    int hebrewYear = (jd - _hebrewEpochJd) ~/ 365 + 3761;

    // Adjust year by searching
    while (jd >= _hebrewNewYearJd(hebrewYear + 1)) {
      hebrewYear++;
    }
    while (jd < _hebrewNewYearJd(hebrewYear)) {
      hebrewYear--;
    }

    // Determine month
    final int dayInYear = jd - _hebrewNewYearJd(hebrewYear);
    int month = 1;
    int daysAccum = 0;

    final int numMonths = monthsInHebrewYear(hebrewYear);
    while (month <= numMonths) {
      final int monthDays = daysInHebrewMonth(hebrewYear, month);
      if (daysAccum + monthDays > dayInYear) {
        break;
      }
      daysAccum += monthDays;
      month++;
    }

    // Determine day
    final int day = dayInYear - daysAccum + 1;

    return (year: hebrewYear, month: month, day: day);
  }

  /// Converts a Gregorian [DateTime] to a Hebrew date.
  ///
  /// Returns a record with:
  /// - `year`: The Hebrew year (e.g., 5785)
  /// - `month`: The month index (1-13)
  /// - `day`: The day of the month (1-30)
  static ({int year, int month, int day}) fromGregorian(DateTime date) {
    final int jd = _gregorianToJulianDay(date);

    return _julianDayToHebrew(jd);
  }

  /// Returns the Hebrew month name for a given month index and year.
  ///
  /// [month] is 1-based (1=Tishrei, 2=Cheshvan, etc.)
  /// [hebrewYear] is needed to handle leap years correctly.
  /// [useHebrew] returns the name in Hebrew script if true.
  static String getMonthName(int month, int hebrewYear, {bool useHebrew = false}) {
    final bool isLeap = isHebrewLeapYear(hebrewYear);
    final List<String> names = useHebrew ? monthNamesHebrew : monthNames;

    if (isLeap) {
      // In leap years, month 6 is Adar I and month 7 is Adar II
      if (month <= 5) {
        return names[month - 1];
      } else if (month == 6) {
        return useHebrew ? 'אֲדָר א׳' : 'Adar I';
      } else if (month == 7) {
        return names[6]; // Adar II
      } else {
        return names[month - 1]; // Nisan onwards
      }
    } else {
      // In non-leap years, skip Adar II (index 6)
      if (month <= 6) {
        return names[month - 1];
      } else {
        return names[month]; // Skip Adar II, go directly to Nisan etc.
      }
    }
  }

  /// Formats a Hebrew day number using Hebrew numerals.
  static String formatDayHebrew(int day) {
    if (day < 1 || day > 30) {
      return day.toString();
    }
    return _hebrewNumerals[day];
  }

  /// Formats a Hebrew year using Hebrew numerals.
  ///
  /// Years are typically written without the thousands digit (5785 → תשפ״ה).
  @useResult
  static String formatYearHebrew(int year) {
    // Remove thousands (5785 → 785)
    final int shortYear = year % 1000;

    return _numberToHebrewNumerals(shortYear);
  }

  /// Converts a number to Hebrew numerals (gematria).
  @useResult
  static String _numberToHebrewNumerals(int number) {
    if (number <= 0) return '';

    final StringBuffer result = StringBuffer();
    int remaining = number;

    // Hundreds
    const List<String> hundreds = <String>['', 'ק', 'ר', 'ש', 'ת', 'תק', 'תר', 'תש', 'תת', 'תתק'];
    if (remaining >= 100) {
      result.write(hundreds[remaining ~/ 100]);
      remaining %= 100;
    }

    // Special cases for 15 and 16 (avoid spelling God's name)
    if (remaining == 15) {
      result.write('ט״ו');
      return result.toString();
    }
    if (remaining == 16) {
      result.write('ט״ז');
      return result.toString();
    }

    // Tens
    const List<String> tens = <String>['', 'י', 'כ', 'ל', 'מ', 'נ', 'ס', 'ע', 'פ', 'צ'];
    if (remaining >= 10) {
      result.write(tens[remaining ~/ 10]);
      remaining %= 10;
    }

    // Units
    const List<String> units = <String>['', 'א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ז', 'ח', 'ט'];
    if (remaining > 0) {
      result.write(units[remaining]);
    }

    // Add gershayim (״) before the last letter
    final String str = result.toString();
    if (str.length > 1) {
      return '${str.substring(0, str.length - 1)}״${str.substring(str.length - 1)}';
    } else if (str.isNotEmpty) {
      return '$str׳';
    }

    return str;
  }

  /// Formats a Hebrew date as a human-readable string.
  ///
  /// [date] is the Gregorian date to convert.
  /// [useHebrew] returns the date in Hebrew script if true.
  ///
  /// Examples:
  /// - English: "1 Tishrei 5785"
  /// - Hebrew: "א׳ תִּשְׁרֵי תשפ״ה"
  static String format(DateTime date, {bool useHebrew = false}) {
    final ({int year, int month, int day}) hebrew = fromGregorian(date);
    final String monthName = getMonthName(hebrew.month, hebrew.year, useHebrew: useHebrew);

    if (useHebrew) {
      final String dayStr = formatDayHebrew(hebrew.day);
      final String yearStr = formatYearHebrew(hebrew.year);
      return '$dayStr $monthName $yearStr';
    } else {
      return '${hebrew.day} $monthName ${hebrew.year}';
    }
  }

  /// Formats a Hebrew date showing only day and month (no year).
  ///
  /// [date] is the Gregorian date to convert.
  /// [useHebrew] returns the date in Hebrew script if true.
  ///
  /// Examples:
  /// - English: "1 Tishrei"
  /// - Hebrew: "א׳ תִּשְׁרֵי"
  static String formatDayMonth(DateTime date, {bool useHebrew = false}) {
    final ({int year, int month, int day}) hebrew = fromGregorian(date);
    final String monthName = getMonthName(hebrew.month, hebrew.year, useHebrew: useHebrew);

    if (useHebrew) {
      return '${formatDayHebrew(hebrew.day)} $monthName';
    } else {
      return '${hebrew.day} $monthName';
    }
  }
}
```

## Test cases — existing tests (verbatim, Hebrew as `\u` escapes)

From `test/lib/utils/primitive/date_time/date_time_primitive_test.dart`
(group `HebrewDateConverter`, lines 445–934). Reproduced verbatim; Hebrew
string literals shown as `\u`-escapes (they compile to the same glyphs).

```dart
group('HebrewDateConverter', () {
  group('isHebrewLeapYear', () {
    test('identifies leap years correctly in a 19-year cycle', () {
      // Leap years are 3, 6, 8, 11, 14, 17, 19 of each 19-year cycle
      // For Hebrew year 5784 (starting at year 1):
      // 5784 mod 19 = 3 (leap year)
      expect(HebrewDateConverter.isHebrewLeapYear(5784), isTrue);

      // 5785 mod 19 = 4 (not leap year)
      expect(HebrewDateConverter.isHebrewLeapYear(5785), isFalse);

      // 5787 mod 19 = 6 (leap year)
      expect(HebrewDateConverter.isHebrewLeapYear(5787), isTrue);

      // 5786 mod 19 = 5 (not leap year)
      expect(HebrewDateConverter.isHebrewLeapYear(5786), isFalse);
    });

    test('returns correct leap year pattern for years 5780-5800', () {
      // Known leap years in this range (years where year % 19 is 0, 3, 6, 8, 11, 14, or 17)
      // 5782 % 19 = 6, 5784 % 19 = 8, 5787 % 19 = 11, 5790 % 19 = 14, 5793 % 19 = 17, 5795 % 19 = 0, 5798 % 19 = 3
      final Set<int> leapYears = <int>{5782, 5784, 5787, 5790, 5793, 5795, 5798};

      for (int year = 5780; year <= 5800; year++) {
        expect(
          HebrewDateConverter.isHebrewLeapYear(year),
          leapYears.contains(year),
          reason: 'Year $year should${leapYears.contains(year) ? '' : ' not'} be a leap year',
        );
      }
    });
  });

  group('monthsInHebrewYear', () {
    test('returns 13 for leap years', () {
      expect(HebrewDateConverter.monthsInHebrewYear(5784), equals(13));
      expect(HebrewDateConverter.monthsInHebrewYear(5787), equals(13));
    });

    test('returns 12 for non-leap years', () {
      expect(HebrewDateConverter.monthsInHebrewYear(5785), equals(12));
      expect(HebrewDateConverter.monthsInHebrewYear(5786), equals(12));
    });
  });

  group('daysInHebrewYear', () {
    test('returns valid year lengths', () {
      // Hebrew years can be 353, 354, 355 (regular) or 383, 384, 385 (leap)
      for (int year = 5780; year <= 5800; year++) {
        final int days = HebrewDateConverter.daysInHebrewYear(year);
        final bool isLeap = HebrewDateConverter.isHebrewLeapYear(year);

        if (isLeap) {
          expect(
            days,
            anyOf(equals(383), equals(384), equals(385)),
            reason: 'Leap year $year should have 383, 384, or 385 days, got $days',
          );
        } else {
          expect(
            days,
            anyOf(equals(353), equals(354), equals(355)),
            reason: 'Regular year $year should have 353, 354, or 355 days, got $days',
          );
        }
      }
    });
  });

  group('daysInHebrewMonth', () {
    test('Tishrei always has 30 days', () {
      expect(HebrewDateConverter.daysInHebrewMonth(5785, 1), equals(30));
      expect(HebrewDateConverter.daysInHebrewMonth(5784, 1), equals(30));
    });

    test('Tevet always has 29 days', () {
      expect(HebrewDateConverter.daysInHebrewMonth(5785, 4), equals(29));
      expect(HebrewDateConverter.daysInHebrewMonth(5784, 4), equals(29));
    });

    test('Shevat always has 30 days', () {
      expect(HebrewDateConverter.daysInHebrewMonth(5785, 5), equals(30));
      expect(HebrewDateConverter.daysInHebrewMonth(5784, 5), equals(30));
    });

    test('Adar I has 30 days in leap year', () {
      expect(HebrewDateConverter.daysInHebrewMonth(5784, 6), equals(30)); // leap year
    });

    test('Adar has 29 days in non-leap year', () {
      expect(HebrewDateConverter.daysInHebrewMonth(5785, 6), equals(29)); // non-leap
    });
  });

  group('fromGregorian - Known Dates', () {
    test('converts Rosh Hashanah 5785 correctly', () {
      // Rosh Hashanah 5785 falls on October 2-4, 2024
      // October 2, 2024 at sunset starts 1 Tishrei 5785
      // In calendar terms, October 3, 2024 is 1 Tishrei 5785
      final DateTime roshHashanah2024 = DateTime(2024, 10, 3);
      final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(
        roshHashanah2024,
      );

      expect(hebrew.year, equals(5785));
      expect(hebrew.month, equals(1)); // Tishrei
      expect(hebrew.day, equals(1));
    });

    test('converts Rosh Hashanah 5784 correctly', () {
      // Rosh Hashanah 5784: September 16, 2023
      final DateTime roshHashanah2023 = DateTime(2023, 9, 16);
      final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(
        roshHashanah2023,
      );

      expect(hebrew.year, equals(5784));
      expect(hebrew.month, equals(1)); // Tishrei
      expect(hebrew.day, equals(1));
    });

    test('converts Yom Kippur 5785 correctly', () {
      // Yom Kippur 5785: October 12, 2024 (10 Tishrei)
      final DateTime yomKippur2024 = DateTime(2024, 10, 12);
      final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(
        yomKippur2024,
      );

      expect(hebrew.year, equals(5785));
      expect(hebrew.month, equals(1)); // Tishrei
      expect(hebrew.day, equals(10));
    });

    test('converts first day of Hanukkah 5785 correctly', () {
      // Hanukkah 5785 starts December 25, 2024 (25 Kislev)
      final DateTime hanukkah2024 = DateTime(2024, 12, 26);
      final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(
        hanukkah2024,
      );

      expect(hebrew.year, equals(5785));
      expect(hebrew.month, equals(3)); // Kislev
      expect(hebrew.day, equals(25));
    });

    test('converts Passover 5785 correctly', () {
      // Passover 5785: April 13, 2025 (15 Nisan)
      final DateTime passover2025 = DateTime(2025, 4, 13);
      final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(
        passover2025,
      );

      expect(hebrew.year, equals(5785));
      expect(hebrew.month, equals(7)); // Nisan (month 8 in leap, 7 in regular)
      expect(hebrew.day, equals(15));
    });

    test('converts Shavuot 5785 correctly', () {
      // Shavuot 5785: June 2, 2025 (6 Sivan)
      final DateTime shavuot2025 = DateTime(2025, 6, 2);
      final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(
        shavuot2025,
      );

      expect(hebrew.year, equals(5785));
      expect(hebrew.month, equals(9)); // Sivan
      expect(hebrew.day, equals(6));
    });

    test('handles dates in Adar during leap year correctly', () {
      // In 5784 (leap year), there are Adar I and Adar II
      // Purim 5784 is on March 24, 2024 (14 Adar II)
      final DateTime purim5784 = DateTime(2024, 3, 24);
      final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(
        purim5784,
      );

      expect(hebrew.year, equals(5784));
      expect(hebrew.month, equals(7)); // Adar II in leap year
      expect(hebrew.day, equals(14));
    });

    test('handles dates in Adar during non-leap year correctly', () {
      // In 5785 (non-leap year), there is only one Adar
      // Purim 5785 is on March 14, 2025 (14 Adar)
      final DateTime purim5785 = DateTime(2025, 3, 14);
      final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(
        purim5785,
      );

      expect(hebrew.year, equals(5785));
      expect(hebrew.month, equals(6)); // Adar (single)
      expect(hebrew.day, equals(14));
    });
  });

  group('fromGregorian - Historical Dates', () {
    test('converts a date from 2000 correctly', () {
      // January 1, 2000 = 23 Tevet 5760
      final DateTime y2k = DateTime(2000, 1, 1);
      final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(y2k);

      expect(hebrew.year, equals(5760));
      expect(hebrew.month, equals(4)); // Tevet
      expect(hebrew.day, equals(23));
    });

    test('converts a date from 1990 correctly', () {
      // January 1, 1990 = 4 Tevet 5750
      final DateTime date1990 = DateTime(1990, 1, 1);
      final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(
        date1990,
      );

      expect(hebrew.year, equals(5750));
      expect(hebrew.month, equals(4)); // Tevet
      expect(hebrew.day, equals(4));
    });
  });

  group('fromGregorian - Future Dates', () {
    test('converts Rosh Hashanah 5786 correctly', () {
      // Rosh Hashanah 5786: September 22, 2025
      final DateTime roshHashanah2025 = DateTime(2025, 9, 23);
      final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(
        roshHashanah2025,
      );

      expect(hebrew.year, equals(5786));
      expect(hebrew.month, equals(1)); // Tishrei
      expect(hebrew.day, equals(1));
    });

    test('converts Rosh Hashanah 5790 correctly', () {
      // Rosh Hashanah 5790: begins sundown September 9, 2029
      // September 10, 2029 is the first full day of 1 Tishrei 5790
      final DateTime roshHashanah2029 = DateTime(2029, 9, 10);
      final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(
        roshHashanah2029,
      );

      expect(hebrew.year, equals(5790));
      expect(hebrew.month, equals(1)); // Tishrei
      expect(hebrew.day, equals(1));
    });
  });

  group('getMonthName', () {
    test('returns correct month names for non-leap year', () {
      expect(HebrewDateConverter.getMonthName(1, 5785), equals('Tishrei'));
      expect(HebrewDateConverter.getMonthName(2, 5785), equals('Cheshvan'));
      expect(HebrewDateConverter.getMonthName(3, 5785), equals('Kislev'));
      expect(HebrewDateConverter.getMonthName(4, 5785), equals('Tevet'));
      expect(HebrewDateConverter.getMonthName(5, 5785), equals('Shevat'));
      expect(HebrewDateConverter.getMonthName(6, 5785), equals('Adar'));
      expect(HebrewDateConverter.getMonthName(7, 5785), equals('Nisan'));
      expect(HebrewDateConverter.getMonthName(8, 5785), equals('Iyar'));
      expect(HebrewDateConverter.getMonthName(9, 5785), equals('Sivan'));
      expect(HebrewDateConverter.getMonthName(10, 5785), equals('Tammuz'));
      expect(HebrewDateConverter.getMonthName(11, 5785), equals('Av'));
      expect(HebrewDateConverter.getMonthName(12, 5785), equals('Elul'));
    });

    test('returns correct month names for leap year', () {
      expect(HebrewDateConverter.getMonthName(1, 5784), equals('Tishrei'));
      expect(HebrewDateConverter.getMonthName(5, 5784), equals('Shevat'));
      expect(HebrewDateConverter.getMonthName(6, 5784), equals('Adar I'));
      expect(HebrewDateConverter.getMonthName(7, 5784), equals('Adar II'));
      expect(HebrewDateConverter.getMonthName(8, 5784), equals('Nisan'));
      expect(HebrewDateConverter.getMonthName(13, 5784), equals('Elul'));
    });

    test('returns Hebrew month names when requested', () {
      expect(HebrewDateConverter.getMonthName(1, 5785, useHebrew: true), equals('תִּשְׁרֵי'));
      expect(HebrewDateConverter.getMonthName(6, 5784, useHebrew: true), equals('אֲדָר א׳'));
      expect(HebrewDateConverter.getMonthName(7, 5784, useHebrew: true), equals('אֲדָר ב׳'));
    });
  });

  group('formatDayHebrew', () {
    test('formats single digit days correctly', () {
      expect(HebrewDateConverter.formatDayHebrew(1), equals('א׳'));
      expect(HebrewDateConverter.formatDayHebrew(5), equals('ה׳'));
      expect(HebrewDateConverter.formatDayHebrew(9), equals('ט׳'));
    });

    test('formats teens correctly', () {
      expect(HebrewDateConverter.formatDayHebrew(10), equals('י׳'));
      expect(HebrewDateConverter.formatDayHebrew(11), equals('י״א'));
      expect(HebrewDateConverter.formatDayHebrew(15), equals('ט״ו')); // Special case
      expect(HebrewDateConverter.formatDayHebrew(16), equals('ט״ז')); // Special case
      expect(HebrewDateConverter.formatDayHebrew(19), equals('י״ט'));
    });

    test('formats twenties correctly', () {
      expect(HebrewDateConverter.formatDayHebrew(20), equals('כ׳'));
      expect(HebrewDateConverter.formatDayHebrew(21), equals('כ״א'));
      expect(HebrewDateConverter.formatDayHebrew(29), equals('כ״ט'));
      expect(HebrewDateConverter.formatDayHebrew(30), equals('ל׳'));
    });
  });

  group('formatYearHebrew', () {
    test('formats year 5785 correctly', () {
      // 5785 -> 785 -> תשפ״ה
      final String formatted = HebrewDateConverter.formatYearHebrew(5785);
      expect(formatted, equals('תשפ״ה'));
    });

    test('formats year 5784 correctly', () {
      // 5784 -> 784 -> תשפ״ד
      final String formatted = HebrewDateConverter.formatYearHebrew(5784);
      expect(formatted, equals('תשפ״ד'));
    });

    test('formats year 5800 correctly', () {
      // 5800 -> 800 -> ת״ת
      final String formatted = HebrewDateConverter.formatYearHebrew(5800);
      expect(formatted, equals('ת״ת'));
    });
  });

  group('format', () {
    test('formats date in English correctly', () {
      final DateTime date = DateTime(2024, 10, 3); // 1 Tishrei 5785
      expect(HebrewDateConverter.format(date), equals('1 Tishrei 5785'));
    });

    test('formats date in Hebrew correctly', () {
      final DateTime date = DateTime(2024, 10, 3); // 1 Tishrei 5785
      final String formatted = HebrewDateConverter.format(date, useHebrew: true);
      expect(formatted, equals('א׳ תִּשְׁרֵי תשפ״ה'));
    });

    test('formats Yom Kippur correctly', () {
      final DateTime date = DateTime(2024, 10, 12); // 10 Tishrei 5785
      expect(HebrewDateConverter.format(date), equals('10 Tishrei 5785'));
    });

    test('formats Hanukkah correctly', () {
      final DateTime date = DateTime(2024, 12, 26); // 25 Kislev 5785
      expect(HebrewDateConverter.format(date), equals('25 Kislev 5785'));
    });
  });

  group('formatDayMonth', () {
    test('formats day and month in English', () {
      final DateTime date = DateTime(2024, 10, 3); // 1 Tishrei
      expect(HebrewDateConverter.formatDayMonth(date), equals('1 Tishrei'));
    });

    test('formats day and month in Hebrew', () {
      final DateTime date = DateTime(2024, 10, 3); // 1 Tishrei
      expect(HebrewDateConverter.formatDayMonth(date, useHebrew: true), equals('א׳ תִּשְׁרֵי'));
    });
  });

  group('Edge cases and boundary tests', () {
    test('handles year boundary (December to January)', () {
      // December 31, 2024 should still be in 5785
      final DateTime dec31 = DateTime(2024, 12, 31);
      final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(dec31);
      expect(hebrew.year, equals(5785));

      // January 1, 2025 should still be in 5785 (until Rosh Hashanah)
      final DateTime jan1 = DateTime(2025, 1, 1);
      final ({int year, int month, int day}) hebrew2 = HebrewDateConverter.fromGregorian(jan1);
      expect(hebrew2.year, equals(5785));
    });

    test('handles Hebrew year boundary correctly', () {
      // Day before Rosh Hashanah 5785 (October 2, 2024) should be 5784
      // 5784 is a leap year, so Elul is month 13 (not 12)
      final DateTime erev = DateTime(2024, 10, 2);
      final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(erev);
      expect(hebrew.year, equals(5784));
      expect(hebrew.month, equals(13)); // Elul (month 13 in leap year)
      expect(hebrew.day, equals(29));
    });

    test('handles month boundaries correctly', () {
      // Last day of Tishrei 5785 (30 Tishrei = October 31-ish)
      // First day of Cheshvan 5785 (1 Cheshvan = November 1-ish)
      final DateTime date1 = DateTime(2024, 11, 1);
      final ({int year, int month, int day}) hebrew1 = HebrewDateConverter.fromGregorian(date1);

      final DateTime date2 = DateTime(2024, 11, 2);
      final ({int year, int month, int day}) hebrew2 = HebrewDateConverter.fromGregorian(date2);

      // One should be end of Tishrei, other should be start of Cheshvan
      // (exact dates depend on calculation)
      expect(hebrew1.year, equals(5785));
      expect(hebrew2.year, equals(5785));
    });

    test('leap year Adar handling is consistent', () {
      // In leap year 5784, verify Adar I and Adar II are sequential
      final DateTime adarI = DateTime(2024, 2, 15); // Should be in Adar I
      final ({int year, int month, int day}) hebrew1 = HebrewDateConverter.fromGregorian(adarI);
      expect(hebrew1.year, equals(5784));
      expect(hebrew1.month, equals(6)); // Adar I

      final DateTime adarII = DateTime(2024, 3, 15); // Should be in Adar II
      final ({int year, int month, int day}) hebrew2 = HebrewDateConverter.fromGregorian(
        adarII,
      );
      expect(hebrew2.year, equals(5784));
      expect(hebrew2.month, equals(7)); // Adar II
    });
  });

  group('Consistency tests', () {
    test('consecutive days increment correctly', () {
      DateTime date = DateTime(2024, 10, 1);
      ({int year, int month, int day}) prevHebrew = HebrewDateConverter.fromGregorian(date);

      for (int i = 0; i < 365; i++) {
        date = DateTime(date.year, date.month, date.day + 1);
        final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(date);

        // Day should increment by 1 (or reset to 1 on new month)
        if (hebrew.month == prevHebrew.month && hebrew.year == prevHebrew.year) {
          expect(
            hebrew.day,
            equals(prevHebrew.day + 1),
            reason: 'Day should increment from ${prevHebrew.day} to ${hebrew.day} on $date',
          );
        } else {
          expect(
            hebrew.day,
            equals(1),
            reason: 'Day should reset to 1 at month boundary on $date',
          );
        }

        prevHebrew = hebrew;
      }
    });

    test('year length matches sum of month lengths', () {
      for (int year = 5780; year <= 5800; year++) {
        final int yearDays = HebrewDateConverter.daysInHebrewYear(year);
        int sumMonthDays = 0;
        final int numMonths = HebrewDateConverter.monthsInHebrewYear(year);

        for (int month = 1; month <= numMonths; month++) {
          sumMonthDays += HebrewDateConverter.daysInHebrewMonth(year, month);
        }

        expect(
          sumMonthDays,
          equals(yearDays),
          reason:
              'Year $year: sum of months ($sumMonthDays) should equal year length ($yearDays)',
        );
      }
    });
  });

  group('Integration with Jewish holidays from static data', () {
    test('Rosh Hashanah dates match expected Hebrew date', () {
      // Test the dates from public_holiday_jewish.dart
      final Map<int, DateTime> roshHashanahDates = <int, DateTime>{
        2024: DateTime(2024, 10, 2),
        2025: DateTime(2025, 9, 22),
        2026: DateTime(2026, 9, 11),
        2027: DateTime(2027, 10, 1),
        2028: DateTime(2028, 9, 20),
        2029: DateTime(2029, 9, 9),
        2030: DateTime(2030, 9, 27),
      };

      for (final MapEntry<int, DateTime> entry in roshHashanahDates.entries) {
        // The day after the evening start is 1 Tishrei
        final DateTime dayAfter = entry.value.add(const Duration(days: 1));
        final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(
          dayAfter,
        );

        expect(hebrew.month, equals(1), reason: 'Rosh Hashanah ${entry.key} should be Tishrei');
        expect(
          hebrew.day,
          equals(1),
          reason: 'Rosh Hashanah ${entry.key} should be 1st of month',
        );
      }
    });
  });
});
```

> Note: the `Integration with Jewish holidays from static data` group references
> the holiday set conceptually (the dates are inlined, not imported), so it
> carries no app dependency and ports as-is. Rename the group if the
> app-fixture reference reads oddly out of context.

## Bulletproofing gaps — concrete cases to add for massive coverage

The existing suite covers the common modern window (Hebrew years ~5750–5800 /
Gregorian ~1990–2030) well: holidays, leap-year Adar I/II, month/year
boundaries, year-length invariants, day increment, gematria 1–30 with the
15/16 special cases. To make it bulletproof, add:

**Extreme / far-range years**
- Conversion at and just after the Hebrew epoch (1 Tishrei year 1 → Julian
  Day 347997): `fromGregorian` on the Gregorian proleptic equivalent; verify
  `year == 1, month == 1, day == 1`.
- Very early Gregorian dates (year 1 CE, year 100, year 1000) — confirm no
  off-by-one in the `_gregorianToJulianDay` proleptic formula and that
  `_julianDayToHebrew`'s `while`-search terminates (the approximate-year seed
  `(jd - epoch) ~/ 365 + 3761` must converge without infinite loop).
- Far-future years (year 3000, 9999) — ensure 64-bit int math doesn't overflow
  and the leap-cycle pattern still holds.
- BCE / negative Gregorian years: `DateTime(-1, ...)`, `DateTime(0, ...)`.
  Decide and assert documented behavior — Hebrew years before the epoch should
  go negative or the converter should define a floor; pin it with a test.

**Leap-year completeness**
- Assert the full 19-year leap pattern over an entire cycle (e.g. years
  5757–5775 covering one complete cycle), not just the 5780–5800 window — verify
  exactly years at cycle-positions {3,6,8,11,14,17,19} are leap.
- Cross-cycle boundary: last leap year of one cycle to first of next.
- `daysInHebrewMonth` for Cheshvan (long vs short) AND Kislev (long vs short)
  in deficient (353/383), regular (354/384), and complete (355/385) years —
  pick concrete years for all six year-length classes and assert each month
  length, not just the always-fixed months.

**Adar edge logic**
- `getMonthName(6, leapYear)` returns "Adar I" and `getMonthName(7, leapYear)`
  returns "Adar II" — covered; add the Hebrew-script counterparts for month 6
  and 7 in a leap year, and confirm month 6 in a NON-leap year is plain "Adar"
  (no roman numeral) in both scripts.
- Round-trip a date in Adar I vs Adar II of the same leap year and confirm the
  `fromGregorian` month indices (6 vs 7) match `getMonthName`.

**`getMonthName` / `formatDayHebrew` boundaries (off-array)**
- `getMonthName` with month `0`, `13` in a non-leap year, `14`, and negative —
  currently indexes `names[month]` / `names[month-1]` with no bounds guard, so
  these throw `RangeError`. Add tests pinning the thrown behavior OR (preferred
  for "bulletproof") add a guard returning empty/`month.toString()` and test it.
- `formatDayHebrew(0)`, `(-1)`, `(31)`, `(100)` — the `< 1 || > 30` guard
  returns `day.toString()`; assert all four explicitly (only 1–30 currently
  tested).

**Gematria (`formatYearHebrew` / `_numberToHebrewNumerals` via public path)**
- `formatYearHebrew` for a year whose short form is exactly a multiple of 100
  with no tens/units (e.g. 5100 → 100 → single hundreds letter) — exercises the
  single-character gershayim-vs-geresh branch (`str.length == 1`).
- Years producing 15/16 in the tens+units position WITH a hundreds prefix
  (e.g. short value 215, 316) — confirm the 15/16 special-case `return` does
  not drop the hundreds already written. (Read the code: the early `return`
  after writing 15/16 includes the hundreds buffer, but this path is untested.)
- `formatYearHebrew` where `year % 1000 == 0` (e.g. 6000) → short value 0 →
  `_numberToHebrewNumerals(0)` returns empty string. Assert the empty result is
  the intended output.
- Negative / zero year into `formatYearHebrew`.

**Formatting / locale**
- `format` and `formatDayMonth` for a leap-year Adar I/II date in both English
  and Hebrew, asserting the full composed string (only Tishrei/Yom Kippur/
  Hanukkah are asserted today).
- Confirm output string length / codepoint count for Hebrew results
  (guard against the niqqud/cantillation marks being silently dropped) — assert
  `result.runes.length` for a known Hebrew month name.

**DateTime input hygiene**
- `fromGregorian` ignores time-of-day: pass `DateTime(2024,10,3,23,59,59)` and
  `DateTime(2024,10,3,0,0,0)` → identical Hebrew date (verify the converter
  uses only y/m/d and is unaffected by the hour). The Hebrew day actually
  starts at sunset, so document that this converter is a civil-date mapping,
  not sunset-aware, and test that hour has no effect.
- UTC vs local `DateTime` with the same y/m/d → identical result
  (`DateTime.utc(2024,10,3)` vs `DateTime(2024,10,3)`).
- A date on a Gregorian leap day (Feb 29, 2024) converts without error.

**Round-trip / invariants (property-style)**
- For a sweep of every day across several decades, assert
  `daysInHebrewMonth` never returns 0 for a valid (year, month) and
  `fromGregorian().day` is always in `1..daysInHebrewMonth(year, month)`.
- Monotonicity: Julian-day-adjacent Gregorian dates never produce a Hebrew
  date that goes backwards.
```
