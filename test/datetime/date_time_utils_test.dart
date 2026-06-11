// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/date_time_utils.dart';

void main() {
  group('DateTimeUtils', () {
    group('calculateAgeAtDeath', () {
      test('returns correct age when both dates are provided', () {
        final DateTime dob = DateTime(1990, 6, 15);
        final DateTime dod = DateTime(2023, 6, 15);
        expect(DateTimeUtils.calculateAgeAtDeath(dob: dob, dod: dod), 33);
      });

      test('returns null if dob is null', () {
        final DateTime dod = DateTime(2023, 6, 15);
        expect(DateTimeUtils.calculateAgeAtDeath(dob: null, dod: dod), isNull);
      });

      test('returns null if dod is null', () {
        final DateTime dob = DateTime(1990, 6, 15);
        expect(DateTimeUtils.calculateAgeAtDeath(dob: dob, dod: null), isNull);
      });

      test('returns null if dod is before dob', () {
        final DateTime dob = DateTime(2023, 6, 15);
        final DateTime dod = DateTime(1990, 6, 15);
        expect(DateTimeUtils.calculateAgeAtDeath(dob: dob, dod: dod), isNull);
      });

      test('handles leap year in dob', () {
        final DateTime dob = DateTime(2000, 2, 29);
        final DateTime dod = DateTime(2023, 6, 15);
        expect(DateTimeUtils.calculateAgeAtDeath(dob: dob, dod: dod), 23);
      });
    });

    group('extractYear', () {
      test('extracts year from string with year at the end', () {
        expect(DateTimeUtils.extractYear('Event in 2023'), 2023);
      });

      test('extracts year from string with year at the beginning', () {
        expect(DateTimeUtils.extractYear('2023 Event'), 2023);
      });

      test('extracts year from string with year in the middle', () {
        expect(DateTimeUtils.extractYear('Event in 2023 happened'), 2023);
      });

      test('returns null if no year is found', () {
        expect(DateTimeUtils.extractYear('No year here'), isNull);
      });

      test('extracts year from string with multiple numbers', () {
        expect(DateTimeUtils.extractYear('In 2023, 123 events happened in 456 days'), 2023);
      });
    });

    group('tomorrow', () {
      test('returns tomorrow at midnight', () {
        final DateTime now = DateTime(2023, 6, 15, 10, 30);
        expect(DateTimeUtils.tomorrow(now: now), DateTime(2023, 6, 16));
      });

      test('returns tomorrow at specified hour', () {
        final DateTime now = DateTime(2023, 6, 15, 10, 30);
        expect(DateTimeUtils.tomorrow(now: now, hour: 12), DateTime(2023, 6, 16, 12));
      });

      test('returns tomorrow at specified hour, minute, and second', () {
        final DateTime now = DateTime(2023, 6, 15, 10, 30);
        expect(
          DateTimeUtils.tomorrow(now: now, hour: 12, minute: 45, second: 30),
          DateTime(2023, 6, 16, 12, 45, 30),
        );
      });

      test('handles crossing month boundaries', () {
        final DateTime now = DateTime(2023, 6, 30, 10, 30);
        expect(DateTimeUtils.tomorrow(now: now), DateTime(2023, 7));
      });

      test('handles crossing year boundaries', () {
        final DateTime now = DateTime(2023, 12, 31, 10, 30);
        expect(DateTimeUtils.tomorrow(now: now), DateTime(2024));
      });
    });

    group('isDateMonthFirst', () {
      test('should return true for en_US', () {
        expect(DateTimeUtils.isDateMonthFirst(localeName: 'en_US'), isTrue);
      });

      test('should return true for en_CA', () {
        expect(DateTimeUtils.isDateMonthFirst(localeName: 'en_CA'), isTrue);
      });

      test('should return true for en_PH', () {
        expect(DateTimeUtils.isDateMonthFirst(localeName: 'en_PH'), isTrue);
      });

      test('should return false for de_DE', () {
        expect(DateTimeUtils.isDateMonthFirst(localeName: 'de_DE'), isFalse);
      });

      test('should return false for en_GB', () {
        expect(DateTimeUtils.isDateMonthFirst(localeName: 'en_GB'), isFalse);
      });

      test('should return false for empty string', () {
        expect(DateTimeUtils.isDateMonthFirst(localeName: ''), isFalse);
      });
    });

    // Note: These tests use average days per year (365.25) and month (30.4375)
    // to account for leap years, providing more accurate calculations.
    group('convertDaysToYearsAndMonths', () {
      test('returns correct string for 366 days (1 year with leap year avg)', () {
        // 366 days / 365.25 = 1.002 years = 1 year
        expect(DateTimeUtils.convertDaysToYearsAndMonths(366), '1 year');
      });

      test('returns correct string for 365 days (11 months with leap year avg)', () {
        // 365 days / 365.25 = 0.999 years = 11 months
        expect(DateTimeUtils.convertDaysToYearsAndMonths(365), '11 months');
      });

      test('returns correct string for 731 days (2 years with leap year avg)', () {
        // 731 days / 365.25 = 2.00 years = 2 years
        expect(DateTimeUtils.convertDaysToYearsAndMonths(731), '2 years');
      });

      test('returns correct string for 31 days (1 month with avg days/month)', () {
        // 31 days / 30.4375 = 1.02 months = 1 month
        expect(DateTimeUtils.convertDaysToYearsAndMonths(31), '1 month');
      });

      test('returns correct string for 61 days (2 months with avg days/month)', () {
        // 61 days / 30.4375 = 2.00 months = 2 months
        expect(DateTimeUtils.convertDaysToYearsAndMonths(61), '2 months');
      });

      test('returns correct string for a combination of years and months', () {
        // 400 days: 400 / 365.25 = 1.09 years = 1 year, remaining ~34 days = 1 month
        expect(DateTimeUtils.convertDaysToYearsAndMonths(400), '1 year and 1 month');
      });

      test('returns null for null input', () {
        expect(DateTimeUtils.convertDaysToYearsAndMonths(null), isNull);
      });

      test('returns null for 0 days', () {
        expect(DateTimeUtils.convertDaysToYearsAndMonths(0), isNull);
      });

      test('returns null for negative days', () {
        expect(DateTimeUtils.convertDaysToYearsAndMonths(-10), isNull);
      });

      test('returns 0 days for small numbers', () {
        expect(DateTimeUtils.convertDaysToYearsAndMonths(10), '0 days');
      });
    });

    group('firstDayNextMonth', () {
      test('returns first day of next month', () {
        expect(DateTimeUtils.firstDayNextMonth(month: 6, year: 2023), DateTime(2023, 7));
      });

      test('handles December to January transition', () {
        expect(DateTimeUtils.firstDayNextMonth(month: 12, year: 2023), DateTime(2024));
      });

      test('handles leap year (February)', () {
        expect(DateTimeUtils.firstDayNextMonth(month: 2, year: 2024), DateTime(2024, 3));
      });

      test('returns null for invalid month', () {
        expect(DateTimeUtils.firstDayNextMonth(month: 13, year: 2023), isNull);
      });

      test('works for January', () {
        expect(DateTimeUtils.firstDayNextMonth(month: 1, year: 2023), DateTime(2023, 2));
      });
    });

    group('maxDate', () {
      test('returns date1 if date2 is null', () {
        final DateTime date1 = DateTime(2023, 6, 15);
        expect(DateTimeUtils.maxDate(date1, null), date1);
      });

      test('returns date2 if it is later', () {
        final DateTime date1 = DateTime(2023, 6, 15);
        final DateTime date2 = DateTime(2023, 6, 16);
        expect(DateTimeUtils.maxDate(date1, date2), date2);
      });

      test('returns date1 if it is later', () {
        final DateTime date1 = DateTime(2023, 6, 16);
        final DateTime date2 = DateTime(2023, 6, 15);
        expect(DateTimeUtils.maxDate(date1, date2), date1);
      });

      test('returns date1 if dates are equal', () {
        final DateTime date1 = DateTime(2023, 6, 15);
        final DateTime date2 = DateTime(2023, 6, 15);
        expect(DateTimeUtils.maxDate(date1, date2), date1);
      });

      test('handles different years', () {
        final DateTime date1 = DateTime(2024, 6, 15);
        final DateTime date2 = DateTime(2023, 6, 15);
        expect(DateTimeUtils.maxDate(date1, date2), date1);
      });
    });

    group('minDate', () {
      test('returns date1 if date2 is null', () {
        final DateTime date1 = DateTime(2023, 6, 15);
        expect(DateTimeUtils.minDate(date1, null), date1);
      });

      test('returns date2 if it is earlier', () {
        final DateTime date1 = DateTime(2023, 6, 16);
        final DateTime date2 = DateTime(2023, 6, 15);
        expect(DateTimeUtils.minDate(date1, date2), date2);
      });

      test('returns date1 if it is earlier', () {
        final DateTime date1 = DateTime(2023, 6, 15);
        final DateTime date2 = DateTime(2023, 6, 16);
        expect(DateTimeUtils.minDate(date1, date2), date1);
      });

      test('returns date1 if dates are equal', () {
        final DateTime date1 = DateTime(2023, 6, 15);
        final DateTime date2 = DateTime(2023, 6, 15);
        expect(DateTimeUtils.minDate(date1, date2), date1);
      });

      test('handles different years', () {
        final DateTime date1 = DateTime(2023, 6, 15);
        final DateTime date2 = DateTime(2024, 6, 15);
        expect(DateTimeUtils.minDate(date1, date2), date1);
      });
    });

    group('isLeapYear', () {
      test('returns true for a leap year', () {
        expect(DateTimeUtils.isLeapYear(year: 2024), isTrue);
      });

      test('returns false for a non-leap year', () {
        expect(DateTimeUtils.isLeapYear(year: 2023), isFalse);
      });

      test('returns true for a year divisible by 400', () {
        expect(DateTimeUtils.isLeapYear(year: 2000), isTrue);
      });

      test('returns false for a year divisible by 100 but not by 400', () {
        expect(DateTimeUtils.isLeapYear(year: 1900), isFalse);
      });

      test('returns false for a year not divisible by 4', () {
        expect(DateTimeUtils.isLeapYear(year: 2022), isFalse);
      });
    });

    group('monthDayCount', () {
      test('returns 31 for January', () {
        expect(DateTimeUtils.monthDayCount(year: 2023, month: 1), 31);
      });

      test('returns 29 for February in a leap year', () {
        expect(DateTimeUtils.monthDayCount(year: 2024, month: 2), 29);
      });

      test('returns 28 for February in a non-leap year', () {
        expect(DateTimeUtils.monthDayCount(year: 2023, month: 2), 28);
      });

      test('returns 30 for April', () {
        expect(DateTimeUtils.monthDayCount(year: 2023, month: 4), 30);
      });

      test('throws ArgumentError for invalid month', () {
        expect(() => DateTimeUtils.monthDayCount(year: 2023, month: 13), throwsArgumentError);
      });
    });

    group('monthDayCountSafe', () {
      // Ported from Saropa Contacts (monthDayCountNullable); raw-int matchers
      // wrapped in equals() per saropa_lints/avoid_misused_test_matchers.
      group('ported sample cases', () {
        test('should return 31 for January in a leap year', () {
          expect(DateTimeUtils.monthDayCountSafe(year: 2024, month: 1), equals(31));
        });

        test('should return 29 for February in a leap year', () {
          expect(DateTimeUtils.monthDayCountSafe(year: 2024, month: 2), equals(29));
        });

        test('should return 28 for February in a non-leap year', () {
          expect(DateTimeUtils.monthDayCountSafe(year: 2023, month: 2), equals(28));
        });

        test('should return 30 for April', () {
          expect(DateTimeUtils.monthDayCountSafe(year: 2024, month: 4), equals(30));
        });
      });

      // The whole reason the nullable variant exists: a null year cannot
      // resolve leap-ness, so February must fall back to its 28-day minimum.
      group('null year branch', () {
        test('should return 28 for February when year is null', () {
          expect(DateTimeUtils.monthDayCountSafe(year: null, month: 2), equals(28));
        });

        test('should return 31 for every 31-day month when year is null', () {
          for (final int month in <int>[1, 3, 5, 7, 8, 10, 12]) {
            expect(
              DateTimeUtils.monthDayCountSafe(year: null, month: month),
              equals(31),
              reason: 'month $month should have 31 days',
            );
          }
        });

        test('should return 30 for every 30-day month when year is null', () {
          for (final int month in <int>[4, 6, 9, 11]) {
            expect(
              DateTimeUtils.monthDayCountSafe(year: null, month: month),
              equals(30),
              reason: 'month $month should have 30 days',
            );
          }
        });
      });

      // Distinct from monthDayCount, which throws on a bad month. This pins
      // the documented (footgun) silent-30 fall-through behavior.
      group('out-of-range month (non-throwing, returns 30)', () {
        test('should return 30 for month 0', () {
          expect(DateTimeUtils.monthDayCountSafe(year: 2024, month: 0), equals(30));
        });

        test('should return 30 for month 13', () {
          expect(DateTimeUtils.monthDayCountSafe(year: 2024, month: 13), equals(30));
        });

        test('should return 30 for month -1', () {
          expect(DateTimeUtils.monthDayCountSafe(year: 2024, month: -1), equals(30));
        });

        test('should return 30 for month 100', () {
          expect(DateTimeUtils.monthDayCountSafe(year: 2024, month: 100), equals(30));
        });

        test('should return 30 for month 1 << 31 without overflow', () {
          expect(DateTimeUtils.monthDayCountSafe(year: 2024, month: 1 << 31), equals(30));
        });

        test('should not throw for a bad month (contrast monthDayCount)', () {
          expect(() => DateTimeUtils.monthDayCountSafe(year: 2024, month: 0), returnsNormally);
          expect(() => DateTimeUtils.monthDayCount(year: 2024, month: 0), throwsArgumentError);
        });
      });

      // Feb day count must track the proleptic Gregorian leap rule at the
      // century / 400-year boundaries.
      group('leap-year boundaries for February', () {
        test('should return 29 for year 2000 (divisible by 400)', () {
          expect(DateTimeUtils.monthDayCountSafe(year: 2000, month: 2), equals(29));
        });

        test('should return 28 for year 1900 (divisible by 100, not 400)', () {
          expect(DateTimeUtils.monthDayCountSafe(year: 1900, month: 2), equals(28));
        });

        test('should return 28 for years 2100, 2200, 2300 (century non-leap)', () {
          for (final int year in <int>[2100, 2200, 2300]) {
            expect(
              DateTimeUtils.monthDayCountSafe(year: year, month: 2),
              equals(28),
              reason: 'year $year is not a leap year',
            );
          }
        });

        test('should return 29 for year 2400 (divisible by 400)', () {
          expect(DateTimeUtils.monthDayCountSafe(year: 2400, month: 2), equals(29));
        });

        test('should return 29 for year 0 (0 % 400 == 0)', () {
          expect(DateTimeUtils.monthDayCountSafe(year: 0, month: 2), equals(29));
        });

        test('should return 29 for year -4 (leap by formula)', () {
          expect(DateTimeUtils.monthDayCountSafe(year: -4, month: 2), equals(29));
        });

        test('should return 28 for year -1 (not divisible by 4)', () {
          expect(DateTimeUtils.monthDayCountSafe(year: -1, month: 2), equals(28));
        });
      });

      // Modulo math must stay well-defined at the int extremes; no crash.
      group('extreme year values', () {
        test('should not crash for year near 2^63 - 1 in February', () {
          const int maxInt = 0x7FFFFFFFFFFFFFFF; // 9223372036854775807, odd → not leap
          expect(DateTimeUtils.monthDayCountSafe(year: maxInt, month: 2), equals(28));
        });

        test('should not crash for minimum int year in February', () {
          // Dart ints are 64-bit two's complement on the VM; -2^63 % 4 == 0,
          // % 100 != 0, so it is a leap year by the proleptic formula.
          const int minInt = -0x8000000000000000;
          expect(DateTimeUtils.monthDayCountSafe(year: minInt, month: 2), equals(29));
        });
      });
    });

    group('isValidDateParts', () {
      test('1. Valid year', () {
        expect(DateTimeUtils.isValidDateParts(year: 2023), isTrue);
      });
      test('2. Year at lower bound', () {
        expect(DateTimeUtils.isValidDateParts(year: 0), isTrue);
      });
      test('3. Year at upper bound', () {
        expect(DateTimeUtils.isValidDateParts(year: 9999), isTrue);
      });
      test('4. Year below lower bound', () {
        expect(DateTimeUtils.isValidDateParts(year: -1), isFalse);
      });
      test('5. Year above upper bound', () {
        expect(DateTimeUtils.isValidDateParts(year: 10000), isFalse);
      });
      test('6. Valid month', () {
        expect(DateTimeUtils.isValidDateParts(month: 6), isTrue);
      });
      test('7. Month at lower bound', () {
        expect(DateTimeUtils.isValidDateParts(month: 1), isTrue);
      });
      test('8. Month at upper bound', () {
        expect(DateTimeUtils.isValidDateParts(month: 12), isTrue);
      });
      test('9. Month below lower bound', () {
        expect(DateTimeUtils.isValidDateParts(month: 0), isFalse);
      });
      test('10. Month above upper bound', () {
        expect(DateTimeUtils.isValidDateParts(month: 13), isFalse);
      });
      test('11. Valid day requires month', () {
        expect(DateTimeUtils.isValidDateParts(day: 15), isFalse);
      });
      test('12. Valid day with month', () {
        expect(DateTimeUtils.isValidDateParts(month: 6, day: 15), isTrue);
      });
      test('13. Day at lower bound', () {
        expect(DateTimeUtils.isValidDateParts(month: 1, day: 1), isTrue);
      });
      test('14. Day at upper bound for 31-day month', () {
        expect(DateTimeUtils.isValidDateParts(month: 1, day: 31), isTrue);
      });
      test('15. Day exceeds month limit', () {
        expect(DateTimeUtils.isValidDateParts(month: 2, day: 30), isFalse);
      });
      test('16. Feb 29 in leap year', () {
        expect(DateTimeUtils.isValidDateParts(year: 2024, month: 2, day: 29), isTrue);
      });
      test('17. Feb 29 in non-leap year', () {
        expect(DateTimeUtils.isValidDateParts(year: 2023, month: 2, day: 29), isFalse);
      });
      test('18. Valid hour', () {
        expect(DateTimeUtils.isValidDateParts(hour: 12), isTrue);
      });
      test('19. Hour at lower bound', () {
        expect(DateTimeUtils.isValidDateParts(hour: 0), isTrue);
      });
      test('20. Hour at upper bound', () {
        expect(DateTimeUtils.isValidDateParts(hour: 23), isTrue);
      });
      test('21. Hour below lower bound', () {
        expect(DateTimeUtils.isValidDateParts(hour: -1), isFalse);
      });
      test('22. Hour above upper bound', () {
        expect(DateTimeUtils.isValidDateParts(hour: 24), isFalse);
      });
      test('23. Valid minute', () {
        expect(DateTimeUtils.isValidDateParts(minute: 30), isTrue);
      });
      test('24. Minute at upper bound', () {
        expect(DateTimeUtils.isValidDateParts(minute: 59), isTrue);
      });
      test('25. Minute above upper bound', () {
        expect(DateTimeUtils.isValidDateParts(minute: 60), isFalse);
      });
      test('26. Valid second', () {
        expect(DateTimeUtils.isValidDateParts(second: 45), isTrue);
      });
      test('27. Second at upper bound', () {
        expect(DateTimeUtils.isValidDateParts(second: 59), isTrue);
      });
      test('28. Second above upper bound', () {
        expect(DateTimeUtils.isValidDateParts(second: 60), isFalse);
      });
      test('29. Valid millisecond', () {
        expect(DateTimeUtils.isValidDateParts(millisecond: 500), isTrue);
      });
      test('30. Millisecond at upper bound', () {
        expect(DateTimeUtils.isValidDateParts(millisecond: 999), isTrue);
      });
      test('31. Millisecond above upper bound', () {
        expect(DateTimeUtils.isValidDateParts(millisecond: 1000), isFalse);
      });
      test('32. Valid microsecond', () {
        expect(DateTimeUtils.isValidDateParts(microsecond: 500), isTrue);
      });
      test('33. Microsecond at upper bound', () {
        expect(DateTimeUtils.isValidDateParts(microsecond: 999), isTrue);
      });
      test('34. Microsecond above upper bound', () {
        expect(DateTimeUtils.isValidDateParts(microsecond: 1000), isFalse);
      });
      test('35. All null returns true', () {
        expect(DateTimeUtils.isValidDateParts(), isTrue);
      });
      test('36. Complete valid date', () {
        expect(
          DateTimeUtils.isValidDateParts(
            year: 2023,
            month: 6,
            day: 15,
            hour: 12,
            minute: 30,
            second: 45,
            millisecond: 500,
            microsecond: 250,
          ),
          isTrue,
        );
      });
      test('37. Invalid date with one bad component', () {
        expect(
          DateTimeUtils.isValidDateParts(
            year: 2023,
            month: 6,
            day: 15,
            hour: 25,
          ),
          isFalse,
        );
      });
      test('38. Day 31 in April (30-day month)', () {
        expect(DateTimeUtils.isValidDateParts(month: 4, day: 31), isFalse);
      });
      test('39. Day 0 is invalid', () {
        expect(DateTimeUtils.isValidDateParts(month: 1, day: 0), isFalse);
      });
      test('40. Negative minute', () {
        expect(DateTimeUtils.isValidDateParts(minute: -1), isFalse);
      });

      // Spec bulletproofing additions: per-month day ceilings, lower-bound
      // day failures, and the library-specific null-year Feb 29 divergence.
      test('41. Day 31 invalid for every 30-day month', () {
        for (final int month in <int>[4, 6, 9, 11]) {
          expect(
            DateTimeUtils.isValidDateParts(month: month, day: 31),
            isFalse,
            reason: 'month $month has only 30 days',
          );
        }
      });

      test('42. Day 30 valid for every 30-day month', () {
        for (final int month in <int>[4, 6, 9, 11]) {
          expect(
            DateTimeUtils.isValidDateParts(month: month, day: 30),
            isTrue,
            reason: 'month $month has 30 days',
          );
        }
      });

      test('43. Negative day is invalid', () {
        expect(DateTimeUtils.isValidDateParts(month: 1, day: -5), isFalse);
      });

      // Library divergence locked: with year null but month==Feb and day==29,
      // _isValidDay falls back to defaultLeapYearCheckYear (2000, a leap year)
      // so the library ACCEPTS, where the Contacts source rejected. This is
      // the intended library semantics.
      test('44. Feb 29 with null year is accepted (defaultLeapYearCheckYear fallback)', () {
        expect(DateTimeUtils.isValidDateParts(month: 2, day: 29), isTrue);
      });

      test('45. Day with null month is invalid', () {
        expect(DateTimeUtils.isValidDateParts(day: 15), isFalse);
      });

      test('46. Very large year is invalid without overflow', () {
        expect(DateTimeUtils.isValidDateParts(year: 0x7FFFFFFFFFFFFFFF), isFalse);
      });

      test('47. Very large hour is invalid without overflow', () {
        expect(DateTimeUtils.isValidDateParts(hour: 0x7FFFFFFFFFFFFFFF), isFalse);
      });
    });
  });
}
