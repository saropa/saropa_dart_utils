import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/hebrew_date_converter.dart';

// cspell:disable
//
// The Hebrew-script and transliteration literals below are calendar data, not
// prose; spell-checking is disabled file-wide to keep the diagnostics focused on
// real issues.

void main() {
  group('HebrewDateConverter', () {
    group('isHebrewLeapYear', () {
      test('should identify leap years correctly in a 19-year cycle', () {
        // Leap years are 3, 6, 8, 11, 14, 17, 19 of each 19-year cycle.
        expect(HebrewDateConverter.isHebrewLeapYear(5784), isTrue);
        expect(HebrewDateConverter.isHebrewLeapYear(5785), isFalse);
        expect(HebrewDateConverter.isHebrewLeapYear(5787), isTrue);
        expect(HebrewDateConverter.isHebrewLeapYear(5786), isFalse);
      });

      test('should return correct leap year pattern for years 5780-5800', () {
        final Set<int> leapYears = <int>{5782, 5784, 5787, 5790, 5793, 5795, 5798};

        for (int year = 5780; year <= 5800; year++) {
          expect(
            HebrewDateConverter.isHebrewLeapYear(year),
            leapYears.contains(year),
            reason: 'Year $year should${leapYears.contains(year) ? '' : ' not'} be a leap year',
          );
        }
      });

      // Bulletproofing: assert the full 19-year leap pattern over one complete
      // cycle (5757-5775), confirming exactly the cycle positions {3,6,8,11,14,
      // 17,19} are leap. 5757 is position 3 of its cycle.
      test('should match the full leap pattern across a complete 19-year cycle', () {
        final Set<int> leapYears = <int>{5757, 5760, 5763, 5765, 5768, 5771, 5774};

        for (int year = 5757; year <= 5775; year++) {
          expect(
            HebrewDateConverter.isHebrewLeapYear(year),
            leapYears.contains(year),
            reason: 'Year $year leap-status mismatch within the cycle',
          );
        }
      });

      // Bulletproofing: cross-cycle boundary — last leap year of one cycle (5776,
      // cycle-position 19) to the first of the next (5779, cycle-position 3), with
      // the non-leap years 5777/5778 between. The closed form `(year*7+1)%19 < 7`
      // places the seventh and final leap of a cycle at position 19, so the last
      // leap is 5776, NOT 5774 (which is position 17, the sixth leap).
      test('should handle the cross-cycle leap boundary', () {
        expect(HebrewDateConverter.isHebrewLeapYear(5776), isTrue); // last of cycle
        expect(HebrewDateConverter.isHebrewLeapYear(5777), isFalse);
        expect(HebrewDateConverter.isHebrewLeapYear(5778), isFalse);
        expect(HebrewDateConverter.isHebrewLeapYear(5779), isTrue); // first of next cycle
      });

      // Bulletproofing: far-future leap math must not overflow 64-bit ints and the
      // 19-cycle must still hold.
      test('should keep the leap cycle correct for far-future years', () {
        // 9999 mod-cycle position is non-leap; 9994 is leap. Verify the closed
        // form stays consistent at large magnitudes (no overflow / sign flip).
        for (int offset = 0; offset < 19; offset++) {
          final int year = 9000 + offset;
          final bool expected = (year * 7 + 1) % 19 < 7;
          expect(HebrewDateConverter.isHebrewLeapYear(year), expected);
        }
      });
    });

    group('monthsInHebrewYear', () {
      test('should return 13 for leap years', () {
        expect(HebrewDateConverter.monthsInHebrewYear(5784), equals(13));
        expect(HebrewDateConverter.monthsInHebrewYear(5787), equals(13));
      });

      test('should return 12 for non-leap years', () {
        expect(HebrewDateConverter.monthsInHebrewYear(5785), equals(12));
        expect(HebrewDateConverter.monthsInHebrewYear(5786), equals(12));
      });
    });

    group('daysInHebrewYear', () {
      test('should return valid year lengths', () {
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
        expect(HebrewDateConverter.daysInHebrewMonth(5784, 6), equals(30));
      });

      test('Adar has 29 days in non-leap year', () {
        expect(HebrewDateConverter.daysInHebrewMonth(5785, 6), equals(29));
      });

      // Bulletproofing: out-of-range month returns 0 (the switch default),
      // signalling an invalid slot rather than a plausible-but-wrong length.
      test('should return 0 for an out-of-range month', () {
        expect(HebrewDateConverter.daysInHebrewMonth(5785, 0), equals(0));
        expect(HebrewDateConverter.daysInHebrewMonth(5785, 13), equals(0)); // no 13 in regular year
        expect(HebrewDateConverter.daysInHebrewMonth(5785, 14), equals(0));
        expect(HebrewDateConverter.daysInHebrewMonth(5785, -1), equals(0));
      });

      // Bulletproofing: Cheshvan (long/short) and Kislev (long/short) across all
      // six year-length classes. Concrete years chosen for each class:
      //   353 -> 5710, 354 -> 5701, 355 -> 5702 (regular)
      //   383 -> 5703, 384 -> 5711, 385 -> 5700 (leap)
      test('should vary Cheshvan and Kislev across deficient/regular/complete years', () {
        // Deficient regular (353): Cheshvan 29, Kislev 29.
        expect(HebrewDateConverter.daysInHebrewYear(5710), equals(353));
        expect(HebrewDateConverter.daysInHebrewMonth(5710, 2), equals(29));
        expect(HebrewDateConverter.daysInHebrewMonth(5710, 3), equals(29));

        // Regular (354): Cheshvan 29, Kislev 30.
        expect(HebrewDateConverter.daysInHebrewYear(5701), equals(354));
        expect(HebrewDateConverter.daysInHebrewMonth(5701, 2), equals(29));
        expect(HebrewDateConverter.daysInHebrewMonth(5701, 3), equals(30));

        // Complete regular (355): Cheshvan 30, Kislev 30.
        expect(HebrewDateConverter.daysInHebrewYear(5702), equals(355));
        expect(HebrewDateConverter.daysInHebrewMonth(5702, 2), equals(30));
        expect(HebrewDateConverter.daysInHebrewMonth(5702, 3), equals(30));

        // Deficient leap (383): Cheshvan 29, Kislev 29.
        expect(HebrewDateConverter.daysInHebrewYear(5703), equals(383));
        expect(HebrewDateConverter.daysInHebrewMonth(5703, 2), equals(29));
        expect(HebrewDateConverter.daysInHebrewMonth(5703, 3), equals(29));

        // Regular leap (384): Cheshvan 29, Kislev 30.
        expect(HebrewDateConverter.daysInHebrewYear(5711), equals(384));
        expect(HebrewDateConverter.daysInHebrewMonth(5711, 2), equals(29));
        expect(HebrewDateConverter.daysInHebrewMonth(5711, 3), equals(30));

        // Complete leap (385): Cheshvan 30, Kislev 30.
        expect(HebrewDateConverter.daysInHebrewYear(5700), equals(385));
        expect(HebrewDateConverter.daysInHebrewMonth(5700, 2), equals(30));
        expect(HebrewDateConverter.daysInHebrewMonth(5700, 3), equals(30));
      });
    });

    group('fromGregorian - Known Dates', () {
      test('converts Rosh Hashanah 5785 correctly', () {
        final DateTime roshHashanah2024 = DateTime(2024, 10, 3);
        final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(
          roshHashanah2024,
        );

        expect(hebrew.year, equals(5785));
        expect(hebrew.month, equals(1)); // Tishrei
        expect(hebrew.day, equals(1));
      });

      test('converts Rosh Hashanah 5784 correctly', () {
        final DateTime roshHashanah2023 = DateTime(2023, 9, 16);
        final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(
          roshHashanah2023,
        );

        expect(hebrew.year, equals(5784));
        expect(hebrew.month, equals(1));
        expect(hebrew.day, equals(1));
      });

      test('converts Yom Kippur 5785 correctly', () {
        final DateTime yomKippur2024 = DateTime(2024, 10, 12);
        final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(
          yomKippur2024,
        );

        expect(hebrew.year, equals(5785));
        expect(hebrew.month, equals(1));
        expect(hebrew.day, equals(10));
      });

      test('converts first day of Hanukkah 5785 correctly', () {
        final DateTime hanukkah2024 = DateTime(2024, 12, 26);
        final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(
          hanukkah2024,
        );

        expect(hebrew.year, equals(5785));
        expect(hebrew.month, equals(3)); // Kislev
        expect(hebrew.day, equals(25));
      });

      test('converts Passover 5785 correctly', () {
        final DateTime passover2025 = DateTime(2025, 4, 13);
        final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(
          passover2025,
        );

        expect(hebrew.year, equals(5785));
        expect(hebrew.month, equals(7)); // Nisan (regular-year display index)
        expect(hebrew.day, equals(15));
      });

      test('converts Shavuot 5785 correctly', () {
        final DateTime shavuot2025 = DateTime(2025, 6, 2);
        final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(
          shavuot2025,
        );

        expect(hebrew.year, equals(5785));
        expect(hebrew.month, equals(9)); // Sivan
        expect(hebrew.day, equals(6));
      });

      test('handles dates in Adar during leap year correctly', () {
        // Purim 5784 is 14 Adar II (March 24, 2024).
        final DateTime purim5784 = DateTime(2024, 3, 24);
        final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(
          purim5784,
        );

        expect(hebrew.year, equals(5784));
        expect(hebrew.month, equals(7)); // Adar II
        expect(hebrew.day, equals(14));
      });

      test('handles dates in Adar during non-leap year correctly', () {
        // Purim 5785 is 14 Adar (March 14, 2025).
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
        final DateTime y2k = DateTime(2000, 1, 1);
        final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(y2k);

        expect(hebrew.year, equals(5760));
        expect(hebrew.month, equals(4)); // Tevet
        expect(hebrew.day, equals(23));
      });

      test('converts a date from 1990 correctly', () {
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
        final DateTime roshHashanah2025 = DateTime(2025, 9, 23);
        final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(
          roshHashanah2025,
        );

        expect(hebrew.year, equals(5786));
        expect(hebrew.month, equals(1));
        expect(hebrew.day, equals(1));
      });

      test('converts Rosh Hashanah 5790 correctly', () {
        final DateTime roshHashanah2029 = DateTime(2029, 9, 10);
        final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(
          roshHashanah2029,
        );

        expect(hebrew.year, equals(5790));
        expect(hebrew.month, equals(1));
        expect(hebrew.day, equals(1));
      });
    });

    // Bulletproofing: extreme / far-range conversions.
    group('fromGregorian - Extreme range', () {
      // The epoch constant (JD 347997) is the day BEFORE 1 Tishrei year 1;
      // 1 Tishrei year 1 is JD 347998, whose proleptic Gregorian date is
      // -3760-09-07. Pin that the first Hebrew day maps to (1, 1, 1).
      test('maps proleptic 1 Tishrei year 1 to year 1, month 1, day 1', () {
        final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(
          DateTime(-3760, 9, 7),
        );

        expect(hebrew.year, equals(1));
        expect(hebrew.month, equals(1));
        expect(hebrew.day, equals(1));
      });

      // Documented floor behavior: the day at the epoch constant itself (JD 347997,
      // one day before 1 Tishrei year 1) falls into Hebrew year 0, NOT a negative
      // year — the while-search converges to year 0 rather than looping. Year 0 is a
      // degenerate proleptic year (its molad-derived length is 321 days, not a real
      // 383-385 leap-year length), so the month/day land where the arithmetic puts
      // them (month 11, day 25), not on a tidy last-month/last-day. Pin the actual
      // output so the boundary is a contract, not an accident.
      test('maps the proleptic day before the epoch to Hebrew year 0', () {
        final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(
          DateTime(-3760, 9, 6),
        );

        expect(hebrew.year, equals(0));
        expect(hebrew.month, equals(11));
        expect(hebrew.day, equals(25));
      });

      // Very early Gregorian dates: confirm the proleptic JD formula and the
      // approximate-year search terminate and produce in-range months/days.
      test('converts very early Gregorian years without off-by-one or hang', () {
        for (final DateTime date in <DateTime>[
          DateTime(1, 1, 1),
          DateTime(100, 1, 1),
          DateTime(1000, 1, 1),
        ]) {
          final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(date);
          expect(hebrew.year, greaterThan(0));
          expect(hebrew.month, inInclusiveRange(1, 13));
          final int dim = HebrewDateConverter.daysInHebrewMonth(hebrew.year, hebrew.month);
          expect(hebrew.day, inInclusiveRange(1, dim));
        }
      });

      // Far-future dates: no 64-bit overflow, search still terminates, output
      // stays internally consistent.
      test('converts far-future Gregorian years consistently', () {
        for (final DateTime date in <DateTime>[
          DateTime(3000, 1, 1),
          DateTime(9999, 12, 31),
        ]) {
          final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(date);
          expect(
            hebrew.month,
            inInclusiveRange(1, HebrewDateConverter.monthsInHebrewYear(hebrew.year)),
          );
          final int dim = HebrewDateConverter.daysInHebrewMonth(hebrew.year, hebrew.month);
          expect(hebrew.day, inInclusiveRange(1, dim));
        }
      });

      // BCE / negative Gregorian years: documented behavior is that Hebrew years
      // remain positive down to year 0 here (these dates are after the epoch),
      // and conversion still terminates with in-range fields.
      test('converts BCE / year-zero Gregorian dates with defined behavior', () {
        for (final DateTime date in <DateTime>[
          DateTime(-1, 1, 1),
          DateTime(0, 1, 1),
        ]) {
          final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(date);
          expect(hebrew.year, greaterThanOrEqualTo(0));
          expect(hebrew.month, inInclusiveRange(1, 13));
          final int dim = HebrewDateConverter.daysInHebrewMonth(hebrew.year, hebrew.month);
          expect(hebrew.day, inInclusiveRange(1, dim));
        }
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

      // Bulletproofing: Adar disambiguation in both scripts and the non-leap
      // plain "Adar" with no roman numeral.
      test('returns plain Adar (no numeral) in a non-leap year in both scripts', () {
        expect(HebrewDateConverter.getMonthName(6, 5785), equals('Adar'));
        expect(HebrewDateConverter.getMonthName(6, 5785, useHebrew: true), equals('אֲדָר'));
      });

      // Bulletproofing: round-trip Adar I vs Adar II of the same leap year and
      // confirm fromGregorian month indices (6 vs 7) match getMonthName.
      test('round-trips Adar I and Adar II of a leap year against getMonthName', () {
        final ({int year, int month, int day}) adarI = HebrewDateConverter.fromGregorian(
          DateTime(2024, 2, 15),
        );
        expect(adarI.year, equals(5784));
        expect(adarI.month, equals(6));
        expect(HebrewDateConverter.getMonthName(adarI.month, adarI.year), equals('Adar I'));

        final ({int year, int month, int day}) adarII = HebrewDateConverter.fromGregorian(
          DateTime(2024, 3, 15),
        );
        expect(adarII.year, equals(5784));
        expect(adarII.month, equals(7));
        expect(HebrewDateConverter.getMonthName(adarII.month, adarII.year), equals('Adar II'));
      });

      // Bulletproofing: off-array month indices. The source indexes the name list
      // with no bounds guard, so these throw RangeError. Pin that contract.
      test('throws RangeError for off-array month indices', () {
        expect(() => HebrewDateConverter.getMonthName(0, 5785), throwsRangeError);
        expect(() => HebrewDateConverter.getMonthName(13, 5785), throwsRangeError);
        expect(() => HebrewDateConverter.getMonthName(14, 5785), throwsRangeError);
        expect(() => HebrewDateConverter.getMonthName(-1, 5785), throwsRangeError);
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
        expect(HebrewDateConverter.formatDayHebrew(15), equals('ט״ו')); // special case
        expect(HebrewDateConverter.formatDayHebrew(16), equals('ט״ז')); // special case
        expect(HebrewDateConverter.formatDayHebrew(19), equals('י״ט'));
      });

      test('formats twenties correctly', () {
        expect(HebrewDateConverter.formatDayHebrew(20), equals('כ׳'));
        expect(HebrewDateConverter.formatDayHebrew(21), equals('כ״א'));
        expect(HebrewDateConverter.formatDayHebrew(29), equals('כ״ט'));
        expect(HebrewDateConverter.formatDayHebrew(30), equals('ל׳'));
      });

      // Bulletproofing: out-of-range days fall back to the decimal string.
      test('falls back to the decimal string for out-of-range days', () {
        expect(HebrewDateConverter.formatDayHebrew(0), equals('0'));
        expect(HebrewDateConverter.formatDayHebrew(-1), equals('-1'));
        expect(HebrewDateConverter.formatDayHebrew(31), equals('31'));
        expect(HebrewDateConverter.formatDayHebrew(100), equals('100'));
      });
    });

    group('formatYearHebrew', () {
      test('formats year 5785 correctly', () {
        expect(HebrewDateConverter.formatYearHebrew(5785), equals('תשפ״ה'));
      });

      test('formats year 5784 correctly', () {
        expect(HebrewDateConverter.formatYearHebrew(5784), equals('תשפ״ד'));
      });

      test('formats year 5800 correctly', () {
        expect(HebrewDateConverter.formatYearHebrew(5800), equals('ת״ת'));
      });

      // Bulletproofing: short form exactly a multiple of 100 with no tens/units
      // exercises the single-character geresh branch (str.length == 1).
      test('formats a hundreds-only short value with a trailing geresh', () {
        // 5100 -> 100 -> single hundreds letter 'ק' -> geresh form 'ק׳'.
        expect(HebrewDateConverter.formatYearHebrew(5100), equals('ק׳'));
      });

      // Bulletproofing: the 15/16 special case WITH a hundreds prefix must keep
      // the hundreds already written (the early return includes the buffer).
      test('keeps the hundreds prefix when tens+units are 15 or 16', () {
        // 215 -> 'ר' + 'ט״ו'; 316 -> 'ש' + 'ט״ז'. Use years 5215 / 5316.
        expect(HebrewDateConverter.formatYearHebrew(5215), equals('רט״ו'));
        expect(HebrewDateConverter.formatYearHebrew(5316), equals('שט״ז'));
      });

      // Bulletproofing: year % 1000 == 0 -> short value 0 -> empty string.
      test('returns empty string when the short year is zero', () {
        expect(HebrewDateConverter.formatYearHebrew(6000), equals(''));
      });

      // Bulletproofing: zero year -> short value 0 -> empty string.
      test('returns empty string for a zero year', () {
        expect(HebrewDateConverter.formatYearHebrew(0), equals(''));
      });

      // Bulletproofing: a negative year does NOT short-circuit to empty. Dart's
      // `%` with a positive divisor is always non-negative ((-5) % 1000 == 995),
      // so the short value is 995 and the gematria is non-empty. Pin the actual
      // Dart-modulo behavior rather than assuming truncated (sign-keeping) modulo.
      test('formats a negative year via non-negative Dart modulo', () {
        // -5 -> 995 -> 'תתקצ״ה'.
        expect(HebrewDateConverter.formatYearHebrew(-5), equals('תתקצ״ה'));
      });
    });

    group('format', () {
      test('formats date in English correctly', () {
        final DateTime date = DateTime(2024, 10, 3); // 1 Tishrei 5785
        expect(HebrewDateConverter.format(date), equals('1 Tishrei 5785'));
      });

      test('formats date in Hebrew correctly', () {
        final DateTime date = DateTime(2024, 10, 3); // 1 Tishrei 5785
        expect(
          HebrewDateConverter.format(date, useHebrew: true),
          equals('א׳ תִּשְׁרֵי תשפ״ה'),
        );
      });

      test('formats Yom Kippur correctly', () {
        final DateTime date = DateTime(2024, 10, 12); // 10 Tishrei 5785
        expect(HebrewDateConverter.format(date), equals('10 Tishrei 5785'));
      });

      test('formats Hanukkah correctly', () {
        final DateTime date = DateTime(2024, 12, 26); // 25 Kislev 5785
        expect(HebrewDateConverter.format(date), equals('25 Kislev 5785'));
      });

      // Bulletproofing: a leap-year Adar I and Adar II date, full composed string,
      // in both English and Hebrew.
      test('formats leap-year Adar I and Adar II dates in both scripts', () {
        // 6 Adar I 5784 (2024-02-15) and 5 Adar II 5784 (2024-03-15).
        expect(HebrewDateConverter.format(DateTime(2024, 2, 15)), equals('6 Adar I 5784'));
        expect(
          HebrewDateConverter.format(DateTime(2024, 2, 15), useHebrew: true),
          equals('ו׳ אֲדָר א׳ תשפ״ד'),
        );
        expect(HebrewDateConverter.format(DateTime(2024, 3, 15)), equals('5 Adar II 5784'));
        expect(
          HebrewDateConverter.format(DateTime(2024, 3, 15), useHebrew: true),
          equals('ה׳ אֲדָר ב׳ תשפ״ד'),
        );
      });

      // Bulletproofing: the Hebrew month name must keep its niqqud — assert the
      // rune count of a known name so silently dropped marks are caught.
      test('preserves niqqud marks in Hebrew month names (rune count)', () {
        // Tishrei with vowel points is 9 code points.
        expect('תִּשְׁרֵי'.runes.length, equals(9));
        final String formatted = HebrewDateConverter.format(DateTime(2024, 10, 3), useHebrew: true);
        expect(formatted.contains('תִּשְׁרֵי'), isTrue);
      });
    });

    group('formatDayMonth', () {
      test('formats day and month in English', () {
        final DateTime date = DateTime(2024, 10, 3); // 1 Tishrei
        expect(HebrewDateConverter.formatDayMonth(date), equals('1 Tishrei'));
      });

      test('formats day and month in Hebrew', () {
        final DateTime date = DateTime(2024, 10, 3); // 1 Tishrei
        expect(
          HebrewDateConverter.formatDayMonth(date, useHebrew: true),
          equals('א׳ תִּשְׁרֵי'),
        );
      });

      // Bulletproofing: leap-year Adar I/II day-month formatting in both scripts.
      test('formats leap-year Adar day-month in both scripts', () {
        expect(HebrewDateConverter.formatDayMonth(DateTime(2024, 2, 15)), equals('6 Adar I'));
        expect(
          HebrewDateConverter.formatDayMonth(DateTime(2024, 2, 15), useHebrew: true),
          equals('ו׳ אֲדָר א׳'),
        );
        expect(HebrewDateConverter.formatDayMonth(DateTime(2024, 3, 15)), equals('5 Adar II'));
      });
    });

    group('DateTime input hygiene', () {
      // Bulletproofing: the converter is a civil-date mapping; the time-of-day
      // must not change the result (it is NOT sunset-aware).
      test('ignores time-of-day', () {
        final ({int year, int month, int day}) endOfDay = HebrewDateConverter.fromGregorian(
          DateTime(2024, 10, 3, 23, 59, 59),
        );
        final ({int year, int month, int day}) startOfDay = HebrewDateConverter.fromGregorian(
          DateTime(2024, 10, 3),
        );

        expect(endOfDay, equals(startOfDay));
      });

      // Bulletproofing: UTC vs local with the same y/m/d produce the same result
      // (only the calendar fields are read).
      test('treats UTC and local DateTime with the same y/m/d identically', () {
        expect(
          HebrewDateConverter.fromGregorian(DateTime.utc(2024, 10, 3)),
          equals(HebrewDateConverter.fromGregorian(DateTime(2024, 10, 3))),
        );
      });

      // Bulletproofing: a Gregorian leap day converts without error.
      test('converts a Gregorian leap day (Feb 29) without error', () {
        final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(
          DateTime(2024, 2, 29),
        );
        expect(hebrew.year, equals(5784));
        expect(hebrew.month, equals(6)); // Adar I
        expect(hebrew.day, equals(20));
      });
    });

    group('Edge cases and boundary tests', () {
      test('handles year boundary (December to January)', () {
        final DateTime dec31 = DateTime(2024, 12, 31);
        final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(dec31);
        expect(hebrew.year, equals(5785));

        final DateTime jan1 = DateTime(2025, 1, 1);
        final ({int year, int month, int day}) hebrew2 = HebrewDateConverter.fromGregorian(jan1);
        expect(hebrew2.year, equals(5785));
      });

      test('handles Hebrew year boundary correctly', () {
        // Day before Rosh Hashanah 5785; 5784 is leap so Elul is month 13.
        final DateTime erev = DateTime(2024, 10, 2);
        final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(erev);
        expect(hebrew.year, equals(5784));
        expect(hebrew.month, equals(13)); // Elul (month 13 in leap year)
        expect(hebrew.day, equals(29));
      });

      test('handles month boundaries correctly', () {
        final DateTime date1 = DateTime(2024, 11, 1);
        final ({int year, int month, int day}) hebrew1 = HebrewDateConverter.fromGregorian(date1);

        final DateTime date2 = DateTime(2024, 11, 2);
        final ({int year, int month, int day}) hebrew2 = HebrewDateConverter.fromGregorian(date2);

        expect(hebrew1.year, equals(5785));
        expect(hebrew2.year, equals(5785));
      });

      test('leap year Adar handling is consistent', () {
        final DateTime adarI = DateTime(2024, 2, 15);
        final ({int year, int month, int day}) hebrew1 = HebrewDateConverter.fromGregorian(adarI);
        expect(hebrew1.year, equals(5784));
        expect(hebrew1.month, equals(6)); // Adar I

        final DateTime adarII = DateTime(2024, 3, 15);
        final ({int year, int month, int day}) hebrew2 = HebrewDateConverter.fromGregorian(
          adarII,
        );
        expect(hebrew2.year, equals(5784));
        expect(hebrew2.month, equals(7)); // Adar II
      });
    });

    group('Consistency tests', () {
      test('consecutive days increment correctly', () {
        DateTime date = DateTime(2024, 10);
        ({int year, int month, int day}) prevHebrew = HebrewDateConverter.fromGregorian(date);

        for (int i = 0; i < 365; i++) {
          date = DateTime(date.year, date.month, date.day + 1);
          final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(date);

          // Day increments by 1 within a month, or resets to 1 at a boundary.
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

    // Bulletproofing: property-style invariants over a multi-decade sweep.
    group('Property-style invariants', () {
      test('day is always within the month length and the month is never zero-length', () {
        DateTime date = DateTime(1980);
        final DateTime end = DateTime(2050);

        while (date.isBefore(end)) {
          final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(date);
          final int dim = HebrewDateConverter.daysInHebrewMonth(hebrew.year, hebrew.month);

          expect(dim, greaterThan(0), reason: 'Zero-length month for $hebrew on $date');
          expect(
            hebrew.day,
            inInclusiveRange(1, dim),
            reason: 'Day ${hebrew.day} out of 1..$dim for $hebrew on $date',
          );

          date = DateTime(date.year, date.month, date.day + 1);
        }
      });

      test('Julian-day-adjacent dates never make the Hebrew date go backwards', () {
        DateTime date = DateTime(2000);
        final DateTime end = DateTime(2010);
        int prevOrdinal = -1 << 60;

        while (date.isBefore(end)) {
          final ({int year, int month, int day}) hebrew = HebrewDateConverter.fromGregorian(date);
          // Compose a strictly-increasing ordinal from (year, month, day). Month
          // and day are bounded (<= 13, <= 30), so these multipliers keep the
          // ordering total without collisions.
          final int ordinal = hebrew.year * 10000 + hebrew.month * 100 + hebrew.day;

          expect(
            ordinal,
            greaterThan(prevOrdinal),
            reason: 'Hebrew date went backwards at $date -> $hebrew',
          );
          prevOrdinal = ordinal;

          date = DateTime(date.year, date.month, date.day + 1);
        }
      });
    });

    group('Integration with Jewish holiday dates', () {
      test('Rosh Hashanah dates match expected Hebrew date', () {
        final Map<int, DateTime> roshHashanahDates = <int, DateTime>{
          2024: DateTime(2024, 10, 2),
          2025: DateTime(2025, 9, 22),
          2026: DateTime(2026, 9, 11),
          2027: DateTime(2027, 10),
          2028: DateTime(2028, 9, 20),
          2029: DateTime(2029, 9, 9),
          2030: DateTime(2030, 9, 27),
        };

        for (final MapEntry<int, DateTime> entry in roshHashanahDates.entries) {
          // The day after the evening start is 1 Tishrei.
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
}
