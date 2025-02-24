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

    group('convertDaysToYearsAndMonths', () {
      test('returns correct string for 365 days', () {
        expect(DateTimeUtils.convertDaysToYearsAndMonths(365), '1 year');
      });

      test('returns correct string for 730 days (2 years)', () {
        expect(DateTimeUtils.convertDaysToYearsAndMonths(730), '2 years');
      });

      test('returns correct string for 30 days (1 month)', () {
        expect(DateTimeUtils.convertDaysToYearsAndMonths(30), '1 month');
      });

      test('returns correct string for 60 days (2 months)', () {
        expect(DateTimeUtils.convertDaysToYearsAndMonths(60), '2 months');
      });

      test('returns correct string for a combination of years and months', () {
        expect(DateTimeUtils.convertDaysToYearsAndMonths(400), '1 year and 1 month');
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
  });
}
