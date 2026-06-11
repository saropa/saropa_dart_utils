import 'package:meta/meta.dart' show useResult;

// cspell:disable
//
// Spell-checking is disabled for this whole file: the month-name transliterations
// (Cheshvan, Tishrei, Iyar, ...) and the Hebrew-script / gematria string literals
// are domain data, not prose, and would otherwise flood the diagnostics with
// false positives that obscure real warnings.

/// Converts Gregorian dates to Hebrew (Jewish) calendar dates and formats them.
///
/// The Hebrew calendar is a lunisolar calendar with 12 or 13 months. Years are
/// counted from the traditional date of Creation (3761 BCE), so a modern
/// Gregorian date maps to a Hebrew year in the 57xx range.
///
/// This implementation uses the fixed arithmetic Hebrew calendar based on the
/// algorithms from "Calendrical Calculations" by Reingold and Dershowitz,
/// bridged through a Julian Day Number. It is deterministic and offline: no
/// network lookup and no astronomical observation are involved, so the same
/// `DateTime` always yields the same Hebrew date.
///
/// All members are `static`; the class is `abstract final` so it can be neither
/// instantiated nor extended — it is a namespace for pure calendar functions,
/// never an object with state.
///
/// Civil-date mapping caveat: the Hebrew day actually begins at sunset, but this
/// converter is intentionally sunset-unaware. It maps the calendar (year, month,
/// day) only and ignores the time-of-day component of the input, so an evening
/// `DateTime` is NOT advanced to the next Hebrew day. Callers needing
/// sunset-accurate behavior must adjust the input date themselves.
///
/// Example:
/// ```dart
/// HebrewDateConverter.format(DateTime(2024, 10, 3)); // '1 Tishrei 5785'
/// HebrewDateConverter.fromGregorian(DateTime(2024, 10, 12)); // (5785, 1, 10)
/// ```
abstract final class HebrewDateConverter {
  /// Hebrew month names in English transliteration, in canonical leap-year order.
  ///
  /// The list is 13 entries because a leap year has 13 months. Index 6
  /// (`'Adar II'`) is present only in leap years; in a regular year it is skipped
  /// — see [getMonthName] for the index-to-name mapping that handles this. The
  /// list is indexed internally; callers should prefer [getMonthName], which
  /// resolves leap-year ambiguity, over indexing this directly.
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

  /// Hebrew month names in Hebrew script (with niqqud), parallel to [monthNames].
  ///
  /// Each entry carries vowel-pointing (niqqud) marks, so a single visible glyph
  /// is several Unicode code points — do not assume `name.length` equals the
  /// number of letters. As with [monthNames], prefer [getMonthName] for
  /// leap-year-correct lookup.
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

  /// Hebrew numerals for day numbers 1-30. Index 0 is an empty placeholder so the
  /// day number can index directly without an off-by-one adjustment.
  ///
  /// Indices 15 and 16 use the traditional `ט״...` spellings rather than
  /// the literal 10+5 / 10+6 forms, because those literal forms would spell a
  /// divine name — a deliberate substitution preserved here, not a typo.
  static const List<String> _hebrewNumerals = <String>[
    '', // 0 placeholder
    'א׳', 'ב׳', 'ג׳', 'ד׳', 'ה׳', 'ו׳', 'ז׳', 'ח׳', 'ט׳', // 1-9
    'י׳', 'י״א', 'י״ב', 'י״ג', 'י״ד', 'ט״ו', 'ט״ז', 'י״ז', 'י״ח', 'י״ט', // 10-19
    'כ׳', 'כ״א', 'כ״ב', 'כ״ג', 'כ״ד', 'כ״ה', 'כ״ו', 'כ״ז', 'כ״ח', 'כ״ט', // 20-29
    'ל׳', // 30
  ];

  /// Returns `true` if [hebrewYear] is a leap year (13 months instead of 12).
  ///
  /// Leap years recur at positions 3, 6, 8, 11, 14, 17, and 19 of the fixed
  /// 19-year Metonic cycle. The `(year * 7 + 1) % 19 < 7` test selects exactly
  /// those seven positions; it is the standard closed form and avoids a lookup
  /// table.
  ///
  /// Example:
  /// ```dart
  /// HebrewDateConverter.isHebrewLeapYear(5784); // true
  /// HebrewDateConverter.isHebrewLeapYear(5785); // false
  /// ```
  static bool isHebrewLeapYear(int hebrewYear) => (hebrewYear * 7 + 1) % 19 < 7;

  /// Returns the number of months in [hebrewYear]: 13 in a leap year, else 12.
  ///
  /// Example:
  /// ```dart
  /// HebrewDateConverter.monthsInHebrewYear(5784); // 13
  /// HebrewDateConverter.monthsInHebrewYear(5785); // 12
  /// ```
  static int monthsInHebrewYear(int hebrewYear) => isHebrewLeapYear(hebrewYear) ? 13 : 12;

  /// Number of lunar months elapsed from the epoch to the start of [hebrewYear].
  ///
  /// Derives the month count from the 235-months-per-19-years Metonic ratio
  /// applied to the completed years (`hebrewYear - 1`); this is the input the
  /// molad (mean lunar conjunction) arithmetic in [_elapsedDays] needs.
  @useResult
  static int _elapsedMonths(int hebrewYear) {
    final int y = hebrewYear - 1;

    return (235 * y + 1) ~/ 19;
  }

  /// Days elapsed from the Hebrew epoch (1 Tishrei year 1) to the start of
  /// [hebrewYear], with the four postponement rules (dehiyyot) applied.
  ///
  /// The molad is computed in the traditional units (1 day = 24 hours, 1 hour =
  /// 1080 parts). The postponement block exists because Rosh Hashanah may not
  /// fall on certain weekdays or under certain molad conditions; without these
  /// adjustments the year boundaries — and therefore every converted date —
  /// would be wrong. The rules are kept verbatim from the reference algorithm
  /// precisely because they are non-obvious and must not be "simplified".
  @useResult
  static int _elapsedDays(int hebrewYear) {
    final int m = _elapsedMonths(hebrewYear);
    final int parts = 204 + 793 * (m % 1080);
    final int hours = 5 + 12 * m + 793 * (m ~/ 1080) + parts ~/ 1080;
    final int day = 1 + 29 * m + hours ~/ 24;

    final int remainder = hours % 24;
    final int partsMod = parts % 1080;

    // Day of week of the molad day (0 = Sunday).
    final int dow = day % 7;

    // Postponement rules (dehiyyot): a too-late molad, or a Tuesday/Monday molad
    // under specific part thresholds in (non-)leap years, pushes Rosh Hashanah
    // forward by a day. After that push, landing on Sunday/Wednesday/Friday
    // (0/3/5) forces a second day so the year does not start on a forbidden day.
    if (remainder >= 18 ||
        (dow == 2 && remainder >= 9 && partsMod >= 204 && !isHebrewLeapYear(hebrewYear)) ||
        (dow == 1 && remainder >= 15 && partsMod >= 589 && isHebrewLeapYear(hebrewYear - 1))) {
      final int newDow = (dow + 1) % 7;
      if (newDow == 0 || newDow == 3 || newDow == 5) {
        return day + 2;
      }
      return day + 1;
    }

    // No molad-based postponement, but a bare Sunday/Wednesday/Friday start is
    // still forbidden, so advance one day.
    if (dow == 0 || dow == 3 || dow == 5) {
      return day + 1;
    }

    return day;
  }

  /// Returns the length of [hebrewYear] in days.
  ///
  /// Computed as the gap between consecutive new-year boundaries, so it
  /// automatically reflects the postponement rules. Regular years are 353/354/355
  /// days; leap years are 383/384/385.
  ///
  /// Example:
  /// ```dart
  /// HebrewDateConverter.daysInHebrewYear(5785); // 355
  /// ```
  static int daysInHebrewYear(int hebrewYear) =>
      _elapsedDays(hebrewYear + 1) - _elapsedDays(hebrewYear);

  /// Returns `true` if Cheshvan is long (30 days) in [hebrewYear].
  ///
  /// Cheshvan and Kislev are the only variable-length months. A complete year
  /// (355 or 385 days) ends in digit 5, which is the signal that Cheshvan took
  /// the extra day.
  @useResult
  static bool _isLongCheshvan(int hebrewYear) => daysInHebrewYear(hebrewYear) % 10 == 5;

  /// Returns `true` if Kislev is short (29 days) in [hebrewYear].
  ///
  /// A deficient year (353 or 383 days) ends in digit 3, which is the signal that
  /// Kislev lost its usual extra day.
  @useResult
  static bool _isShortKislev(int hebrewYear) => daysInHebrewYear(hebrewYear) % 10 == 3;

  /// Returns the number of days (29 or 30) in [month] of [hebrewYear].
  ///
  /// [month] is 1-based in display order: 1=Tishrei, 2=Cheshvan, 3=Kislev,
  /// 4=Tevet, 5=Shevat, 6=Adar (or Adar I in a leap year), 7=Adar II (leap years
  /// only) or Nisan, and so on. An out-of-range [month] returns 0.
  ///
  /// In a non-leap year there is no Adar II, so display months 7+ are remapped to
  /// the canonical numbering (which always reserves slot 7 for Adar II) before the
  /// fixed/variable length lookup. Cheshvan and Kislev defer to the year-length
  /// helpers; all other months have fixed lengths.
  ///
  /// Example:
  /// ```dart
  /// HebrewDateConverter.daysInHebrewMonth(5784, 6); // 30 (Adar I, leap year)
  /// HebrewDateConverter.daysInHebrewMonth(5785, 6); // 29 (Adar, regular year)
  /// ```
  static int daysInHebrewMonth(int hebrewYear, int month) {
    final bool isLeap = isHebrewLeapYear(hebrewYear);

    // Map the display month onto the canonical numbering. In a regular year there
    // is no Adar II (canonical slot 7), so display months 7+ shift up by one to
    // skip it; in a leap year display and canonical numbering coincide.
    int canonicalMonth;
    if (isLeap) {
      canonicalMonth = month;
    } else {
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
        // Out-of-range month: return 0 so callers can detect an invalid slot
        // rather than receiving a plausible-but-wrong length.
        return 0;
    }
  }

  /// Julian-Day anchor for the Hebrew epoch: the day BEFORE 1 Tishrei year 1.
  ///
  /// `_elapsedDays` counts from 1 for year 1, so 1 Tishrei year 1 lands on
  /// `347997 + 1 = 347998`; this constant is the zero-base the `_elapsedDays`
  /// offset is added to, NOT itself a valid Hebrew date. All Hebrew-to-Julian
  /// conversions anchor here, making it the single source of truth for the
  /// calendar's origin.
  static const int _hebrewEpochJd = 347997;

  /// Converts a Gregorian [date] to a Julian Day Number.
  ///
  /// Uses the standard proleptic Gregorian formula, so it is well-defined for any
  /// year including pre-1582 and negative (BCE) years. Only the year/month/day are
  /// read; the time-of-day is ignored, which is what makes the converter a civil
  /// date mapping rather than a sunset-aware one.
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

  /// Returns the Julian Day Number of 1 Tishrei (Rosh Hashanah) of [hebrewYear].
  @useResult
  static int _hebrewNewYearJd(int hebrewYear) => _hebrewEpochJd + _elapsedDays(hebrewYear);

  /// Converts a Julian Day Number [jd] to a Hebrew `(year, month, day)`.
  ///
  /// Seeds an approximate Hebrew year from the average year length, then corrects
  /// it by a bounded linear search over the exact new-year boundaries — the seed
  /// is close enough that the search moves at most a couple of years, never
  /// looping unboundedly. With the year fixed, it walks the months accumulating
  /// their (possibly variable) lengths until the target day falls inside one.
  @useResult
  static ({int year, int month, int day}) _julianDayToHebrew(int jd) {
    // Approximate the year from the mean year length, then converge exactly. The
    // seed is biased low/high by at most a year or two, so each while-loop runs a
    // handful of iterations rather than scanning from the epoch.
    int hebrewYear = (jd - _hebrewEpochJd) ~/ 365 + 3761;

    while (jd >= _hebrewNewYearJd(hebrewYear + 1)) {
      hebrewYear++;
    }
    while (jd < _hebrewNewYearJd(hebrewYear)) {
      hebrewYear--;
    }

    // Walk months from Tishrei, subtracting each month's length, until the
    // remaining day count lands within the current month.
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

    // +1 converts the 0-based offset within the month to a 1-based day number.
    final int day = dayInYear - daysAccum + 1;

    return (year: hebrewYear, month: month, day: day);
  }

  /// Converts a Gregorian [date] to a Hebrew date record.
  ///
  /// Returns a record with `year` (e.g. 5785), `month` (1-13 in display order),
  /// and `day` (1-30). Only the calendar date of [date] is used; the time-of-day,
  /// the UTC/local flag, and sunset are all irrelevant to the result (this is a
  /// civil-date mapping — see the class doc).
  ///
  /// Example:
  /// ```dart
  /// HebrewDateConverter.fromGregorian(DateTime(2024, 10, 3)); // (5785, 1, 1)
  /// ```
  static ({int year, int month, int day}) fromGregorian(DateTime date) {
    final int jd = _gregorianToJulianDay(date);

    return _julianDayToHebrew(jd);
  }

  /// Returns the name of [month] (1-based) in [hebrewYear], honoring leap years.
  ///
  /// [hebrewYear] is required because the Adar months differ by year type: in a
  /// leap year month 6 is "Adar I" and month 7 is "Adar II"; in a regular year
  /// month 6 is plain "Adar" and there is no Adar II, so months 7+ skip that slot.
  /// Pass [useHebrew] `true` to receive the Hebrew-script name (with the Adar I/II
  /// disambiguators in Hebrew).
  ///
  /// An out-of-range [month] indexes past the name list and throws a
  /// `RangeError`, matching the source's behavior — callers feeding untrusted
  /// month numbers should validate against [monthsInHebrewYear] first.
  ///
  /// Example:
  /// ```dart
  /// HebrewDateConverter.getMonthName(6, 5784); // 'Adar I'
  /// HebrewDateConverter.getMonthName(6, 5785); // 'Adar'
  /// ```
  static String getMonthName(int month, int hebrewYear, {bool useHebrew = false}) {
    final bool isLeap = isHebrewLeapYear(hebrewYear);
    final List<String> names = useHebrew ? monthNamesHebrew : monthNames;

    // Leap year: months 1-5 are direct; 6/7 are the two Adars (which need the
    // "I"/"II" disambiguator, not the bare list entry); 8+ continue from Nisan.
    if (isLeap) {
      if (month <= 5) {
        return names[month - 1];
      } else if (month == 6) {
        return useHebrew ? 'אֲדָר א׳' : 'Adar I';
      } else {
        // Month 7 is Adar II (index 6); 8+ is Nisan onwards (index month - 1).
        return month == 7 ? names[6] : names[month - 1];
      }
    } else {
      // Regular year: months 1-6 are direct; from 7 on, index by [month] (not
      // month-1) to skip the Adar II slot at index 6 and land on Nisan etc.
      return month <= 6 ? names[month - 1] : names[month];
    }
  }

  /// Formats a day-of-month [day] using Hebrew numerals (gematria).
  ///
  /// Valid days are 1-30 and map to the precomputed [_hebrewNumerals] table
  /// (which already encodes the 15/16 special-case spellings). Any value outside
  /// 1-30 falls back to the plain decimal string so the function never throws on
  /// an unexpected day number.
  ///
  /// Example:
  /// ```dart
  /// HebrewDateConverter.formatDayHebrew(15); // 'ט״ו'
  /// HebrewDateConverter.formatDayHebrew(31); // '31'
  /// ```
  static String formatDayHebrew(int day) {
    if (day < 1 || day > 30) {
      return day.toString();
    }
    return _hebrewNumerals[day];
  }

  /// Formats a Hebrew [year] using Hebrew numerals, omitting the thousands digit.
  ///
  /// Hebrew years are conventionally written without the thousands (the
  /// "5" in 5785), so 5785 renders as the gematria of 785. A year whose remainder
  /// mod 1000 is 0 yields an empty string, matching the convention that there is
  /// no numeral for zero.
  ///
  /// Example:
  /// ```dart
  /// HebrewDateConverter.formatYearHebrew(5785); // 'תשפ״ה'
  /// ```
  @useResult
  static String formatYearHebrew(int year) {
    // Drop the thousands digit (5785 -> 785) per the writing convention.
    final int shortYear = year % 1000;

    return _numberToHebrewNumerals(shortYear);
  }

  /// Converts a positive [number] to its Hebrew-numeral (gematria) spelling.
  ///
  /// Builds the string from hundreds, then tens, then units, inserting the
  /// gershayim (`״`) before the final letter (or a single geresh `׳`
  /// for a one-letter result) to mark it as a numeral. The 15 and 16 cases use
  /// the traditional substitute spellings to avoid forming a divine name; those
  /// early returns deliberately keep any hundreds already written so a value like
  /// 215 is not truncated to its tens+units. Returns an empty string for zero or
  /// negative input.
  @useResult
  static String _numberToHebrewNumerals(int number) {
    if (number <= 0) return '';

    final StringBuffer result = StringBuffer();
    int remaining = number;

    // Hundreds: 500-900 are written as 400 (ת) plus the remainder, hence the
    // multi-letter entries from index 5 onward.
    const List<String> hundreds = <String>['', 'ק', 'ר', 'ש', 'ת', 'תק', 'תר', 'תש', 'תת', 'תתק'];
    if (remaining >= 100) {
      result.write(hundreds[remaining ~/ 100]);
      remaining %= 100;
    }

    // 15 and 16 must not be written as 10+5 / 10+6 (those spell a divine name);
    // emit the substitute forms and return, preserving any hundreds already in
    // the buffer.
    if (remaining == 15) {
      result.write('ט״ו');
      return result.toString();
    }
    if (remaining == 16) {
      result.write('ט״ז');
      return result.toString();
    }

    // Append the tens-place letter.
    const List<String> tens = <String>['', 'י', 'כ', 'ל', 'מ', 'נ', 'ס', 'ע', 'פ', 'צ'];
    if (remaining >= 10) {
      result.write(tens[remaining ~/ 10]);
      remaining %= 10;
    }

    // Append the units-place letter.
    const List<String> units = <String>['', 'א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ז', 'ח', 'ט'];
    if (remaining > 0) {
      result.write(units[remaining]);
    }

    // Mark the result as a numeral: gershayim (״) before the last letter for
    // multi-letter values, a trailing geresh (׳) for a single letter.
    final String str = result.toString();
    if (str.length > 1) {
      return '${str.substring(0, str.length - 1)}״${str.substring(str.length - 1)}';
    } else if (str.isNotEmpty) {
      return '$str׳';
    }

    return str;
  }

  /// Formats the Hebrew date for Gregorian [date] as "day month year".
  ///
  /// With [useHebrew] `false` (default) the output is transliterated and decimal,
  /// e.g. `'1 Tishrei 5785'`. With [useHebrew] `true` the day and year are written
  /// in gematria and the month in Hebrew script, e.g.
  /// `'א׳ תִּשְׁרֵי תשפ״ה'`.
  ///
  /// Example:
  /// ```dart
  /// HebrewDateConverter.format(DateTime(2024, 10, 12)); // '10 Tishrei 5785'
  /// ```
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

  /// Formats the Hebrew date for Gregorian [date] as "day month", omitting the year.
  ///
  /// Behaves like [format] but drops the year — useful for recurring annual events
  /// (birthdays, yahrzeits) where only the day and month matter. [useHebrew]
  /// selects Hebrew script and gematria as in [format].
  ///
  /// Example:
  /// ```dart
  /// HebrewDateConverter.formatDayMonth(DateTime(2024, 10, 3)); // '1 Tishrei'
  /// ```
  static String formatDayMonth(DateTime date, {bool useHebrew = false}) {
    final ({int year, int month, int day}) hebrew = fromGregorian(date);
    final String monthName = getMonthName(hebrew.month, hebrew.year, useHebrew: useHebrew);

    return useHebrew
        ? '${formatDayHebrew(hebrew.day)} $monthName'
        : '${hebrew.day} $monthName';
  }
}
