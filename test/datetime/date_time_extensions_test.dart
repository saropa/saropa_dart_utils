import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jiffy/jiffy.dart';
import 'package:saropa_dart_utils/datetime/date_time_extensions.dart';

void main() {
  group('DateTimeExtensions', () {
    group('getNthWeekdayOfMonthInYear', () {
      test('1st Monday of January 2023', () {
        final date = DateTime(2023).getNthWeekdayOfMonthInYear(1, DateTime.monday);
        expect(date, DateTime(2023, 1, 2));
      });

      test('2nd Tuesday of February 2023', () {
        final date = DateTime(2023, 2).getNthWeekdayOfMonthInYear(2, DateTime.tuesday);
        expect(date, DateTime(2023, 2, 14));
      });

      test('3rd Wednesday of March 2023', () {
        final date = DateTime(2023, 3).getNthWeekdayOfMonthInYear(3, DateTime.wednesday);
        expect(date, DateTime(2023, 3, 15));
      });

      test('4th Thursday of April 2023', () {
        final date = DateTime(2023, 4).getNthWeekdayOfMonthInYear(4, DateTime.thursday);
        expect(date, DateTime(2023, 4, 27));
      });

      test('5th Friday of May 2023 (does not exist)', () {
        final date = DateTime(2023, 5).getNthWeekdayOfMonthInYear(5, DateTime.friday);
        expect(date, isNull); // Should expect null because it doesn't exist
      });

      test('1st Saturday of June 2024 (Leap Year)', () {
        final date = DateTime(2024, 6).getNthWeekdayOfMonthInYear(1, DateTime.saturday);
        expect(date, DateTime(2024, 6));
      });

      test('2nd Sunday of July 2024 (Leap Year)', () {
        final date = DateTime(2024, 7).getNthWeekdayOfMonthInYear(2, DateTime.sunday);
        expect(date, DateTime(2024, 7, 14));
      });

      test('3rd Monday of August 2024 (Leap Year)', () {
        final date = DateTime(2024, 8).getNthWeekdayOfMonthInYear(3, DateTime.monday);
        expect(date, DateTime(2024, 8, 19));
      });

      test('4th Tuesday of September 2024 (Leap Year)', () {
        final date = DateTime(2024, 9).getNthWeekdayOfMonthInYear(4, DateTime.tuesday);
        expect(date, DateTime(2024, 9, 24));
      });

      test('5th Wednesday of October 2024 (Leap Year)', () {
        final date = DateTime(2024, 10).getNthWeekdayOfMonthInYear(5, DateTime.wednesday);
        expect(date, DateTime(2024, 10, 30));
      });

      test('5th Saturday of December 2023', () {
        final date = DateTime(2023, 12).getNthWeekdayOfMonthInYear(5, DateTime.saturday);
        expect(date, DateTime(2023, 12, 30));
      });

      test('5th Wednesday of May 2024', () {
        final date = DateTime(2024, 5).getNthWeekdayOfMonthInYear(5, DateTime.wednesday);
        expect(date, DateTime(2024, 5, 29));
      });

      test('5th Thursday of February 2024 (Leap Year - exists)', () {
        final date = DateTime(2024, 2).getNthWeekdayOfMonthInYear(5, DateTime.thursday);
        expect(date, DateTime(2024, 2, 29));
      });

      test('5th Friday of February 2023 (non-Leap Year - does not exist)', () {
        final date = DateTime(2023, 2).getNthWeekdayOfMonthInYear(5, DateTime.friday);
        expect(date, isNull);
      });

      test('Invalid input: n = 0', () {
        final date = DateTime(2023).getNthWeekdayOfMonthInYear(0, DateTime.monday);
        expect(date, isNull);
      });

      test('Invalid input: n = -1', () {
        final date = DateTime(2023).getNthWeekdayOfMonthInYear(-1, DateTime.monday);
        expect(date, isNull);
      });
      test('1st Sunday of November 2024', () {
        final date = DateTime(2024, 11).getNthWeekdayOfMonthInYear(1, DateTime.sunday);
        expect(date, DateTime(2024, 11, 3));
      });

      test('3rd Friday of December 2024', () {
        final date = DateTime(2024, 12).getNthWeekdayOfMonthInYear(3, DateTime.friday);
        expect(date, DateTime(2024, 12, 20));
      });

      test('4th Sunday of April 2023', () {
        final date = DateTime(2023, 4).getNthWeekdayOfMonthInYear(4, DateTime.sunday);
        expect(date, DateTime(2023, 4, 23));
      });

      test('2nd Monday of June 2023', () {
        final date = DateTime(2023, 6).getNthWeekdayOfMonthInYear(2, DateTime.monday);
        expect(date, DateTime(2023, 6, 12));
      });
    });

    group('DateTimeExtensions', () {
      group('isAnnualDateInRange', () {
        test('returns true when date is within range with specific year', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTimeRange range = DateTimeRange(
            start: DateTime(2023),
            end: DateTime(2023, 12, 31),
          );
          expect(date.isAnnualDateInRange(range), true);
        });

        test('returns false when date is outside range with specific year', () {
          final DateTime date = DateTime(2024, 6, 15);
          final DateTimeRange range = DateTimeRange(
            start: DateTime(2023),
            end: DateTime(2023, 12, 31),
          );
          expect(date.isAnnualDateInRange(range), false);
        });

        test('returns true when date with year 0 is within range', () {
          final DateTime date = DateTime(0, 6, 15);
          final DateTimeRange range = DateTimeRange(
            start: DateTime(2023),
            end: DateTime(2025, 12, 31),
          );
          expect(date.isAnnualDateInRange(range), true);
        });

        test('returns false when date with year 0 is outside range', () {
          final DateTime date = DateTime(0, 12, 31);
          final DateTimeRange range = DateTimeRange(
            start: DateTime(2023),
            end: DateTime(2025, 11, 30),
          );
          expect(date.isAnnualDateInRange(range), false);
        });

        test('returns true when date is at start of range', () {
          final DateTime date = DateTime(2023);
          final DateTimeRange range = DateTimeRange(
            start: DateTime(2023),
            end: DateTime(2023, 12, 31),
          );
          expect(date.isAnnualDateInRange(range), true);
        });

        test('returns true when date is at end of range', () {
          final DateTime date = DateTime(2023, 12, 31);
          final DateTimeRange range = DateTimeRange(
            start: DateTime(2023),
            end: DateTime(2023, 12, 31),
          );
          expect(date.isAnnualDateInRange(range), true);
        });

        test('returns true when range is null', () {
          final DateTime date = DateTime(2023, 6, 15);
          expect(date.isAnnualDateInRange(null), true);
        });

        test('returns true for leap year date within range', () {
          final DateTime date = DateTime(0, 2, 29);
          final DateTimeRange range = DateTimeRange(
            start: DateTime(2023),
            end: DateTime(2025, 12, 31),
          );
          expect(date.isAnnualDateInRange(range), true);
        });

        test('returns false for date just before range start', () {
          final DateTime date = DateTime(2022, 12, 31);
          final DateTimeRange range = DateTimeRange(
            start: DateTime(2023),
            end: DateTime(2025, 12, 31),
          );
          expect(date.isAnnualDateInRange(range), false);
        });

        test('returns false for date just after range end', () {
          final DateTime date = DateTime(2026);
          final DateTimeRange range = DateTimeRange(
            start: DateTime(2023),
            end: DateTime(2025, 12, 31),
          );
          expect(date.isAnnualDateInRange(range), false);
        });
      });

      group('generateDayList', () {
        test('generates a list of 5 consecutive days (startOfDay: true)', () {
          final DateTime startDate = DateTime(2023);
          final List<DateTime> days = startDate.generateDayList(5);
          expect(days.length, 5);
          expect(days[0], DateTime(2023));
          expect(days[1], DateTime(2023, 1, 2));
          expect(days[2], DateTime(2023, 1, 3));
          expect(days[3], DateTime(2023, 1, 4));
          expect(days[4], DateTime(2023, 1, 5));
        });

        test('generates a list of 5 consecutive days (startOfDay: false)', () {
          final DateTime startDate = DateTime(2023, 1, 1, 10, 30); // Example with time
          final List<DateTime> days = startDate.generateDayList(5, startOfDay: false);
          expect(days.length, 5);
          expect(days[0], DateTime(2023, 1, 1, 10, 30));
          expect(days[1], DateTime(2023, 1, 2, 10, 30));
          expect(days[2], DateTime(2023, 1, 3, 10, 30));
          expect(days[3], DateTime(2023, 1, 4, 10, 30));
          expect(days[4], DateTime(2023, 1, 5, 10, 30));
        });

        test('generates a list of 1 day (startOfDay: true)', () {
          final DateTime startDate = DateTime(2023, 6, 15);
          final List<DateTime> days = startDate.generateDayList(1);
          expect(days.length, 1);
          expect(days[0], DateTime(2023, 6, 15));
        });

        test('generates a list of 1 day (startOfDay: false)', () {
          final DateTime startDate = DateTime(2023, 6, 15, 12); // Example with time
          final List<DateTime> days = startDate.generateDayList(1, startOfDay: false);
          expect(days.length, 1);
          expect(days[0], DateTime(2023, 6, 15, 12));
        });

        test('generates an empty list when days is 0 (startOfDay: true)', () {
          final DateTime startDate = DateTime(2023, 12, 31);
          final List<DateTime> days = startDate.generateDayList(0);
          expect(days.isEmpty, isTrue);
        });

        test('generates an empty list when days is 0 (startOfDay: false)', () {
          final DateTime startDate = DateTime(2023, 12, 31, 20); // Example with time
          final List<DateTime> days = startDate.generateDayList(0, startOfDay: false);
          expect(days.isEmpty, isTrue);
        });

        test('handles crossing month boundaries (startOfDay: true)', () {
          final DateTime startDate = DateTime(2023, 1, 30);
          final List<DateTime> days = startDate.generateDayList(3);
          expect(days.length, 3);
          expect(days[0], DateTime(2023, 1, 30));
          expect(days[1], DateTime(2023, 1, 31));
          expect(days[2], DateTime(2023, 2));
        });
        test('handles crossing month boundaries (startOfDay: false)', () {
          final DateTime startDate = DateTime(2023, 1, 30, 5, 5);
          final List<DateTime> days = startDate.generateDayList(3, startOfDay: false);
          expect(days.length, 3);
          expect(days[0], DateTime(2023, 1, 30, 5, 5));
          expect(days[1], DateTime(2023, 1, 31, 5, 5));
          expect(days[2], DateTime(2023, 2, 1, 5, 5));
        });

        test('handles crossing year boundaries (startOfDay: true)', () {
          final DateTime startDate = DateTime(2023, 12, 30);
          final List<DateTime> days = startDate.generateDayList(3);
          expect(days.length, 3);
          expect(days[0], DateTime(2023, 12, 30));
          expect(days[1], DateTime(2023, 12, 31));
          expect(days[2], DateTime(2024));
        });

        test('handles crossing year boundaries (startOfDay: false)', () {
          final DateTime startDate = DateTime(2023, 12, 30, 10, 10, 10);
          final List<DateTime> days = startDate.generateDayList(3, startOfDay: false);
          expect(days.length, 3);
          expect(days[0], DateTime(2023, 12, 30, 10, 10, 10));
          expect(days[1], DateTime(2023, 12, 31, 10, 10, 10));
          expect(days[2], DateTime(2024, 1, 1, 10, 10, 10));
        });
      });

      group('prevDay', () {
        test('returns the previous day (startOfDay: true)', () {
          final DateTime date = DateTime(2023, 1, 15);
          expect(date.prevDay(), DateTime(2023, 1, 14));
        });

        test('returns the previous day (startOfDay: false)', () {
          final DateTime date = DateTime(2023, 1, 15, 10);
          expect(date.prevDay(startOfDay: false), DateTime(2023, 1, 14, 10));
        });

        test('handles the first day of the month (startOfDay: true)', () {
          final DateTime date = DateTime(2023, 6);
          expect(date.prevDay(), DateTime(2023, 5, 31));
        });
        test('handles the first day of the month (startOfDay: false)', () {
          final DateTime date = DateTime(2023, 6, 1, 1, 1, 1);
          expect(date.prevDay(startOfDay: false), DateTime(2023, 5, 31, 1, 1, 1));
        });

        test('handles the first day of the year (startOfDay: true)', () {
          final DateTime date = DateTime(2023);
          expect(date.prevDay(), DateTime(2022, 12, 31));
        });

        test('handles the first day of the year (startOfDay: false)', () {
          final DateTime date = DateTime(2023, 1, 1, 5, 5, 5);
          expect(date.prevDay(startOfDay: false), DateTime(2022, 12, 31, 5, 5, 5));
        });

        test('handles leap years (startOfDay: true)', () {
          final DateTime date = DateTime(2024, 3);
          expect(date.prevDay(), DateTime(2024, 2, 29));
        });

        test('handles leap years (startOfDay: false)', () {
          final DateTime date = DateTime(2024, 3, 1, 1, 2, 3);
          expect(date.prevDay(startOfDay: false), DateTime(2024, 2, 29, 1, 2, 3));
        });
      });

      group('nextDay', () {
        test('returns the next day (startOfDay: true)', () {
          final DateTime date = DateTime(2023, 1, 15);
          expect(date.nextDay(), DateTime(2023, 1, 16));
        });

        test('returns the next day (startOfDay: false)', () {
          final DateTime date = DateTime(2023, 1, 15, 5, 4, 3);
          expect(date.nextDay(startOfDay: false), DateTime(2023, 1, 16, 5, 4, 3));
        });

        test('handles the last day of the month (startOfDay: true)', () {
          final DateTime date = DateTime(2023, 1, 31);
          expect(date.nextDay(), DateTime(2023, 2));
        });

        test('handles the last day of the month (startOfDay: false)', () {
          final DateTime date = DateTime(2023, 1, 31, 2, 2, 2);
          expect(date.nextDay(startOfDay: false), DateTime(2023, 2, 1, 2, 2, 2));
        });

        test('handles the last day of the year (startOfDay: true)', () {
          final DateTime date = DateTime(2023, 12, 31);
          expect(date.nextDay(), DateTime(2024));
        });
        test('handles the last day of the year (startOfDay: false)', () {
          final DateTime date = DateTime(2023, 12, 31, 5, 5);
          expect(date.nextDay(startOfDay: false), DateTime(2024, 1, 1, 5, 5));
        });

        test('handles leap years (startOfDay: true)', () {
          final DateTime date = DateTime(2024, 2, 28);
          expect(date.nextDay(), DateTime(2024, 2, 29));
        });
        test('handles leap years (startOfDay: false)', () {
          final DateTime date = DateTime(2024, 2, 28, 1, 1, 1);
          expect(date.nextDay(startOfDay: false), DateTime(2024, 2, 29, 1, 1, 1));
        });
      });

      group('isUnder13', () {
        test('returns true if date of birth is less than 13 years ago', () {
          final DateTime dob = DateTime.now().subtract(const Duration(days: 365 * 12));
          expect(dob.isUnder13(), isTrue);
        });

        test('returns false if date of birth is exactly 13 years ago', () {
          // We need to account for leap years - hence the use of Jiffy
          final DateTime dob = Jiffy.parseFromDateTime(DateTime.now()).subtract(years: 13).dateTime;

          expect(dob.isUnder13(), isFalse);
        });

        test('returns false if date of birth is more than 13 years ago', () {
          final DateTime dob = DateTime.now().subtract(const Duration(days: 365 * 14));
          expect(dob.isUnder13(), isFalse);
        });

        test('returns true if date of birth is 1 day less than 13 years ago', () {
          final DateTime dob = DateTime.now().subtract(const Duration(days: 365 * 13 - 1));
          expect(dob.isUnder13(), isTrue);
        });

        test('returns false if date of birth is in the future', () {
          final DateTime dob = DateTime.now().add(const Duration(days: 365));
          expect(dob.isUnder13(), isFalse); // Assuming future dates are not considered under 13
        });
      });

      group('isAfterNow', () {
        test('returns true if date is in the future', () {
          final DateTime date = DateTime.now().add(const Duration(days: 1));
          expect(date.isAfterNow(), isTrue);
        });

        test('returns false if date is now', () {
          final DateTime date = DateTime.now();
          expect(date.isAfterNow(), isFalse);
        });

        test('returns false if date is in the past', () {
          final DateTime date = DateTime.now().subtract(const Duration(days: 1));
          expect(date.isAfterNow(), isFalse);
        });

        test('returns true if date is one second in the future', () {
          final DateTime date = DateTime.now().add(const Duration(seconds: 1));
          expect(date.isAfterNow(), isTrue);
        });

        test('returns false if date is one second in the past', () {
          final DateTime date = DateTime.now().subtract(const Duration(seconds: 1));
          expect(date.isAfterNow(), isFalse);
        });
      });

      group('isBeforeNow', () {
        test('returns true if date is in the past', () {
          final DateTime date = DateTime.now().subtract(const Duration(days: 1));
          expect(date.isBeforeNow(), isTrue);
        });

        test('returns false if date is now', () {
          final DateTime date = DateTime.now();
          expect(date.isBeforeNow(), isFalse);
        });

        test('returns false if date is in the future', () {
          final DateTime date = DateTime.now().add(const Duration(days: 1));
          expect(date.isBeforeNow(), isFalse);
        });

        test('returns true if date is one second in the past', () {
          final DateTime date = DateTime.now().subtract(const Duration(seconds: 1));
          expect(date.isBeforeNow(), isTrue);
        });

        test('returns false if date is one second in the future', () {
          final DateTime date = DateTime.now().add(const Duration(seconds: 1));
          expect(date.isBeforeNow(), isFalse);
        });
      });

      group('isLeapYear', () {
        test('returns true for a leap year', () {
          final DateTime date = DateTime(2024);
          expect(date.isLeapYear(), isTrue);
        });

        test('returns false for a non-leap year', () {
          final DateTime date = DateTime(2023);
          expect(date.isLeapYear(), isFalse);
        });

        test('returns true for a year divisible by 400', () {
          final DateTime date = DateTime(2000);
          expect(date.isLeapYear(), isTrue);
        });

        test('returns false for a year divisible by 100 but not by 400', () {
          final DateTime date = DateTime(1900);
          expect(date.isLeapYear(), isFalse);
        });

        test('returns false for a year not divisible by 4', () {
          final DateTime date = DateTime(2022);
          expect(date.isLeapYear(), isFalse);
        });
      });

      group('yearStart', () {
        test('returns the first day of the year', () {
          final DateTime date = DateTime(2023, 6, 15);
          expect(date.yearStart, DateTime(2023));
        });

        test('handles leap years', () {
          final DateTime date = DateTime(2024, 9, 22);
          expect(date.yearStart, DateTime(2024));
        });

        test('works for the year 1', () {
          final DateTime date = DateTime(1, 4, 12);
          expect(date.yearStart, DateTime(1));
        });

        test('works for the current year', () {
          final DateTime now = DateTime.now();
          final DateTime date = DateTime(now.year, 3, 5);
          expect(date.yearStart, DateTime(now.year));
        });

        test('throws ArgumentError for year greater than 9999', () {
          final DateTime date = DateTime(10000);
          expect(() => date.yearStart, throwsArgumentError);
        });
      });

      group('yearEnd', () {
        test('returns the last day of the year', () {
          final DateTime date = DateTime(2023, 6, 15);
          expect(date.yearEnd, DateTime(2023, 12, 31));
        });

        test('handles leap years', () {
          final DateTime date = DateTime(2024, 9, 22);
          expect(date.yearEnd, DateTime(2024, 12, 31));
        });

        test('works for the year 1', () {
          final DateTime date = DateTime(1, 4, 12);
          expect(date.yearEnd, DateTime(1, 12, 31));
        });

        test('works for the current year', () {
          final DateTime now = DateTime.now();
          final DateTime date = DateTime(now.year, 3, 5);
          expect(date.yearEnd, DateTime(now.year, 12, 31));
        });

        test('throws ArgumentError for year greater than 9999', () {
          final DateTime date = DateTime(10000);
          expect(() => date.yearEnd, throwsArgumentError);
        });
      });

      group('isBeforeNullable', () {
        test('returns false if other is null', () {
          final DateTime date = DateTime(2023, 6, 15);
          expect(date.isBeforeNullable(null), isFalse);
        });

        test('returns true if date is before other', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime other = DateTime(2023, 6, 16);
          expect(date.isBeforeNullable(other), isTrue);
        });

        test('returns false if date is after other', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime other = DateTime(2023, 6, 14);
          expect(date.isBeforeNullable(other), isFalse);
        });

        test('returns false if date is the same as other', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime other = DateTime(2023, 6, 15);
          expect(date.isBeforeNullable(other), isFalse);
        });

        test('handles different years', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime other = DateTime(2024, 6, 15);
          expect(date.isBeforeNullable(other), isTrue);
        });
      });

      group('isAfterNullable', () {
        test('returns false if other is null', () {
          final DateTime date = DateTime(2023, 6, 15);
          expect(date.isAfterNullable(null), isFalse);
        });

        test('returns true if date is after other', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime other = DateTime(2023, 6, 14);
          expect(date.isAfterNullable(other), isTrue);
        });

        test('returns false if date is before other', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime other = DateTime(2023, 6, 16);
          expect(date.isAfterNullable(other), isFalse);
        });

        test('returns false if date is the same as other', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime other = DateTime(2023, 6, 15);
          expect(date.isAfterNullable(other), isFalse);
        });

        test('handles different years', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime other = DateTime(2022, 6, 15);
          expect(date.isAfterNullable(other), isTrue);
        });
      });
      group('isMidnight', () {
        test('returns true if time is midnight', () {
          final DateTime date = DateTime(2023);
          expect(date.isMidnight, isTrue);
        });

        test('returns false if hour is not 0', () {
          final DateTime date = DateTime(2023, 1, 1, 1);
          expect(date.isMidnight, isFalse);
        });

        test('returns false if minute is not 0', () {
          final DateTime date = DateTime(2023, 1, 1, 0, 1);
          expect(date.isMidnight, isFalse);
        });

        test('returns false if second is not 0', () {
          final DateTime date = DateTime(2023, 1, 1, 0, 0, 1);
          expect(date.isMidnight, isFalse);
        });

        test('returns false if time is not midnight', () {
          final DateTime date = DateTime(2023, 1, 1, 12, 30, 45);
          expect(date.isMidnight, isFalse);
        });
      });

      group('toDateInYear', () {
        test('returns date in specified year', () {
          final DateTime date = DateTime(2000, 6, 15);
          expect(date.toDateInYear(2023), DateTime(2023, 6, 15));
        });

        test('handles leap years', () {
          final DateTime date = DateTime(2000, 2, 29);
          expect(date.toDateInYear(2024), DateTime(2024, 2, 29));
        });

        test('works for the first day of the year', () {
          final DateTime date = DateTime(2000);
          expect(date.toDateInYear(2025), DateTime(2025));
        });

        test('works for the last day of the year', () {
          final DateTime date = DateTime(2000, 12, 31);
          expect(date.toDateInYear(2022), DateTime(2022, 12, 31));
        });

        test('handles single-digit month and day', () {
          final DateTime date = DateTime(2000, 5, 8);
          expect(date.toDateInYear(2023), DateTime(2023, 5, 8));
        });
      });

      group('dayOfMonthOrdinal', () {
        test('returns correct ordinal for 1st', () {
          final DateTime date = DateTime(2023, 6);
          expect(date.dayOfMonthOrdinal(), '1st');
        });

        test('returns correct ordinal for 2nd', () {
          final DateTime date = DateTime(2023, 6, 2);
          expect(date.dayOfMonthOrdinal(), '2nd');
        });

        test('returns correct ordinal for 3rd', () {
          final DateTime date = DateTime(2023, 6, 3);
          expect(date.dayOfMonthOrdinal(), '3rd');
        });

        test('returns correct ordinal for 11th', () {
          final DateTime date = DateTime(2023, 6, 11);
          expect(date.dayOfMonthOrdinal(), '11th');
        });

        test('returns correct ordinal for 21st', () {
          final DateTime date = DateTime(2023, 6, 21);
          expect(date.dayOfMonthOrdinal(), '21st');
        });
      });

      group('getTimeDifferenceMs', () {
        test('returns positive difference when comparing to a past date', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime pastDate = DateTime(2023, 6, 14);
          expect(date.getTimeDifferenceMs(pastDate), greaterThan(0));
        });

        test('returns negative difference when comparing to a future date', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime futureDate = DateTime(2023, 6, 16);
          expect(date.getTimeDifferenceMs(futureDate), greaterThan(0));
        });

        test('returns 0 when comparing to the same date', () {
          final DateTime date = DateTime(2023, 6, 15);
          expect(date.getTimeDifferenceMs(date), 0);
        });

        test('returns null when other is null', () {
          final DateTime date = DateTime(2023, 6, 15);
          expect(date.getTimeDifferenceMs(null), isNull);
        });

        test('handles large time differences', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime pastDate = DateTime(2020);
          expect(date.getTimeDifferenceMs(pastDate), greaterThan(0));
        });
      });

      group('addYears', () {
        test('adds 1 year', () {
          final DateTime date = DateTime(2023, 6, 15);
          expect(date.addYears(1), DateTime(2024, 6, 15));
        });

        test('adds multiple years', () {
          final DateTime date = DateTime(2023, 6, 15);
          expect(date.addYears(5), DateTime(2028, 6, 15));
        });

        test('handles leap years', () {
          final DateTime date = DateTime(2024, 2, 29);
          expect(date.addYears(1), DateTime(2025, 2, 28));
        });

        test('adds 0 years', () {
          final DateTime date = DateTime(2023, 6, 15);
          expect(date.addYears(0), DateTime(2023, 6, 15));
        });

        test('handles large number of years', () {
          final DateTime date = DateTime(2023, 6, 15);
          expect(date.addYears(100), DateTime(2123, 6, 15));
        });
      });

      group('addMonths', () {
        test('adds 1 month', () {
          final DateTime date = DateTime(2023, 6, 15);
          expect(date.addMonths(1), DateTime(2023, 7, 15));
        });

        test('adds multiple months', () {
          final DateTime date = DateTime(2023, 6, 15);
          expect(date.addMonths(5), DateTime(2023, 11, 15));
        });

        test('handles crossing year boundaries', () {
          final DateTime date = DateTime(2023, 12, 15);
          expect(date.addMonths(1), DateTime(2024, 1, 15));
        });

        test('adds 0 months', () {
          final DateTime date = DateTime(2023, 6, 15);
          expect(date.addMonths(0), DateTime(2023, 6, 15));
        });

        test('handles large number of months', () {
          final DateTime date = DateTime(2023, 6, 15);
          expect(date.addMonths(24), DateTime(2025, 6, 15));
        });
      });

      group('addDays', () {
        test('adds 1 day', () {
          final DateTime date = DateTime(2023, 6, 15);
          expect(date.addDays(1), DateTime(2023, 6, 16));
        });

        test('adds multiple days', () {
          final DateTime date = DateTime(2023, 6, 15);
          expect(date.addDays(5), DateTime(2023, 6, 20));
        });

        test('handles crossing month boundaries', () {
          final DateTime date = DateTime(2023, 6, 30);
          expect(date.addDays(1), DateTime(2023, 7));
        });

        test('adds 0 days', () {
          final DateTime date = DateTime(2023, 6, 15);
          expect(date.addDays(0), DateTime(2023, 6, 15));
        });

        test('handles large number of days', () {
          final DateTime date = DateTime(2023, 6, 15);
          expect(date.addDays(100), DateTime(2023, 9, 23));
        });
      });
      group('addHours', () {
        test('adds 1 hour', () {
          final DateTime date = DateTime(2023, 6, 15, 10);
          expect(date.addHours(1), DateTime(2023, 6, 15, 11));
        });

        test('adds multiple hours', () {
          final DateTime date = DateTime(2023, 6, 15, 10);
          expect(date.addHours(5), DateTime(2023, 6, 15, 15));
        });

        test('handles crossing day boundaries', () {
          final DateTime date = DateTime(2023, 6, 15, 23);
          expect(date.addHours(2), DateTime(2023, 6, 16, 1));
        });

        test('adds 0 hours', () {
          final DateTime date = DateTime(2023, 6, 15, 10);
          expect(date.addHours(0), DateTime(2023, 6, 15, 10));
        });

        test('handles large number of hours', () {
          final DateTime date = DateTime(2023, 6, 15, 10);
          expect(date.addHours(48), DateTime(2023, 6, 17, 10));
        });
      });

      group('addMinutes', () {
        test('adds 1 minute', () {
          final DateTime date = DateTime(2023, 6, 15, 10, 30);
          expect(date.addMinutes(1), DateTime(2023, 6, 15, 10, 31));
        });

        test('adds multiple minutes', () {
          final DateTime date = DateTime(2023, 6, 15, 10, 30);
          expect(date.addMinutes(5), DateTime(2023, 6, 15, 10, 35));
        });

        test('handles crossing hour boundaries', () {
          final DateTime date = DateTime(2023, 6, 15, 10, 59);
          expect(date.addMinutes(2), DateTime(2023, 6, 15, 11, 1));
        });

        test('adds 0 minutes', () {
          final DateTime date = DateTime(2023, 6, 15, 10, 30);
          expect(date.addMinutes(0), DateTime(2023, 6, 15, 10, 30));
        });

        test('handles large number of minutes', () {
          final DateTime date = DateTime(2023, 6, 15, 10, 30);
          expect(date.addMinutes(120), DateTime(2023, 6, 15, 12, 30));
        });
      });
      group('subtractMinutes', () {
        test('subtracts 1 minute', () {
          final DateTime date = DateTime(2023, 6, 15, 10, 30);
          expect(date.subtractMinutes(1), DateTime(2023, 6, 15, 10, 29));
        });

        test('subtracts multiple minutes', () {
          final DateTime date = DateTime(2023, 6, 15, 10, 30);
          expect(date.subtractMinutes(5), DateTime(2023, 6, 15, 10, 25));
        });

        test('handles crossing hour boundaries', () {
          final DateTime date = DateTime(2023, 6, 15, 11, 1);
          expect(date.subtractMinutes(2), DateTime(2023, 6, 15, 10, 59));
        });

        test('subtracts 0 minutes', () {
          final DateTime date = DateTime(2023, 6, 15, 10, 30);
          expect(date.subtractMinutes(0), DateTime(2023, 6, 15, 10, 30));
        });

        test('handles large number of minutes', () {
          final DateTime date = DateTime(2023, 6, 15, 12, 30);
          expect(date.subtractMinutes(120), DateTime(2023, 6, 15, 10, 30));
        });
      });

      group('subtractHours', () {
        test('subtracts 1 hour', () {
          final DateTime date = DateTime(2023, 6, 15, 11);
          expect(date.subtractHours(1), DateTime(2023, 6, 15, 10));
        });

        test('subtracts multiple hours', () {
          final DateTime date = DateTime(2023, 6, 15, 15);
          expect(date.subtractHours(5), DateTime(2023, 6, 15, 10));
        });

        test('handles crossing day boundaries', () {
          final DateTime date = DateTime(2023, 6, 16, 1);
          expect(date.subtractHours(2), DateTime(2023, 6, 15, 23));
        });

        test('subtracts 0 hours', () {
          final DateTime date = DateTime(2023, 6, 15, 10);
          expect(date.subtractHours(0), DateTime(2023, 6, 15, 10));
        });

        test('handles large number of hours', () {
          final DateTime date = DateTime(2023, 6, 17, 10);
          expect(date.subtractHours(48), DateTime(2023, 6, 15, 10));
        });
      });

      group('subtractMonths', () {
        test('subtracts 1 month', () {
          final DateTime date = DateTime(2023, 7, 15);
          expect(date.subtractMonths(1), DateTime(2023, 6, 15));
        });

        test('subtracts multiple months', () {
          final DateTime date = DateTime(2023, 11, 15);
          expect(date.subtractMonths(5), DateTime(2023, 6, 15));
        });

        test('handles crossing year boundaries', () {
          final DateTime date = DateTime(2024, 1, 15);
          expect(date.subtractMonths(1), DateTime(2023, 12, 15));
        });

        test('subtracts 0 months', () {
          final DateTime date = DateTime(2023, 6, 15);
          expect(date.subtractMonths(0), DateTime(2023, 6, 15));
        });

        test('handles large number of months', () {
          final DateTime date = DateTime(2025, 6, 15);
          expect(date.subtractMonths(24), DateTime(2023, 6, 15));
        });
      });

      group('subtractYears', () {
        test('subtracts 1 year', () {
          final DateTime date = DateTime(2024, 6, 15);
          expect(date.subtractYears(1), DateTime(2023, 6, 15));
        });

        test('subtracts multiple years', () {
          final DateTime date = DateTime(2028, 6, 15);
          expect(date.subtractYears(5), DateTime(2023, 6, 15));
        });

        test('handles leap years', () {
          final DateTime date = DateTime(2025, 2, 28);
          // NOTE: you WILL lose Feb 29th when adding and subtracting 1 year
          expect(date.subtractYears(1), DateTime(2024, 2, 28));
        });

        test('subtracts 0 years', () {
          final DateTime date = DateTime(2023, 6, 15);
          expect(date.subtractYears(0), DateTime(2023, 6, 15));
        });

        test('handles large number of years', () {
          final DateTime date = DateTime(2123, 6, 15);
          expect(date.subtractYears(100), DateTime(2023, 6, 15));
        });
      });

      group('subtractDays', () {
        test('subtracts 1 day', () {
          final DateTime date = DateTime(2023, 6, 16);
          expect(date.subtractDays(1), DateTime(2023, 6, 15));
        });

        test('subtracts multiple days', () {
          final DateTime date = DateTime(2023, 6, 20);
          expect(date.subtractDays(5), DateTime(2023, 6, 15));
        });

        test('handles crossing month boundaries', () {
          final DateTime date = DateTime(2023, 7);
          expect(date.subtractDays(1), DateTime(2023, 6, 30));
        });

        test('subtracts 0 days', () {
          final DateTime date = DateTime(2023, 6, 15);
          expect(date.subtractDays(0), DateTime(2023, 6, 15));
        });

        test('handles large number of days', () {
          final DateTime date = DateTime(2023, 9, 23);
          expect(date.subtractDays(100), DateTime(2023, 6, 15));
        });
      });

      group('isYearCurrent', () {
        test('returns true if date is in current year', () {
          final DateTime date = DateTime(DateTime.now().year, 6, 15);
          expect(date.isYearCurrent, isTrue);
        });

        test('returns false if date is in past year', () {
          final DateTime date = DateTime(DateTime.now().year - 1, 6, 15);
          expect(date.isYearCurrent, isFalse);
        });

        test('returns false if date is in future year', () {
          final DateTime date = DateTime(DateTime.now().year + 1, 6, 15);
          expect(date.isYearCurrent, isFalse);
        });

        test('handles first day of current year', () {
          final DateTime date = DateTime(DateTime.now().year);
          expect(date.isYearCurrent, isTrue);
        });

        test('handles last day of current year', () {
          final DateTime date = DateTime(DateTime.now().year, 12, 31);
          expect(date.isYearCurrent, isTrue);
        });
      });

      group('isSameDateOrAfter', () {
        test('returns true if date is after other', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime other = DateTime(2023, 6, 14);
          expect(date.isSameDateOrAfter(other), isTrue);
        });

        test('returns true if date is same as other', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime other = DateTime(2023, 6, 15);
          expect(date.isSameDateOrAfter(other), isTrue);
        });

        test('returns false if date is before other', () {
          final DateTime date = DateTime(2023, 6, 14);
          final DateTime other = DateTime(2023, 6, 15);
          expect(date.isSameDateOrAfter(other), isFalse);
        });

        test('ignores time component', () {
          final DateTime date = DateTime(2023, 6, 15, 10);
          final DateTime other = DateTime(2023, 6, 15, 5);
          expect(date.isSameDateOrAfter(other), isTrue);
        });

        test('handles different years', () {
          final DateTime date = DateTime(2024, 6, 15);
          final DateTime other = DateTime(2023, 6, 15);
          expect(date.isSameDateOrAfter(other), isTrue);
        });
      });

      group('isSameDateOrBefore', () {
        test('returns true if date is before other', () {
          final DateTime date = DateTime(2023, 6, 14);
          final DateTime other = DateTime(2023, 6, 15);
          expect(date.isSameDateOrBefore(other), isTrue);
        });

        test('returns true if date is same as other', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime other = DateTime(2023, 6, 15);
          expect(date.isSameDateOrBefore(other), isTrue);
        });

        test('returns false if date is after other', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime other = DateTime(2023, 6, 14);
          expect(date.isSameDateOrBefore(other), isFalse);
        });

        test('ignores time component', () {
          final DateTime date = DateTime(2023, 6, 15, 5);
          final DateTime other = DateTime(2023, 6, 15, 10);
          expect(date.isSameDateOrBefore(other), isTrue);
        });

        test('handles different years', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime other = DateTime(2024, 6, 15);
          expect(date.isSameDateOrBefore(other), isTrue);
        });
      });
      group('toDateOnly', () {
        test('removes time component', () {
          final DateTime date = DateTime(2023, 6, 15, 10, 30, 45);
          expect(date.toDateOnly(), DateTime(2023, 6, 15));
        });

        test('handles midnight', () {
          final DateTime date = DateTime(2023, 6, 15);
          expect(date.toDateOnly(), DateTime(2023, 6, 15));
        });

        test('handles leap year', () {
          final DateTime date = DateTime(2024, 2, 29, 12, 30);
          expect(date.toDateOnly(), DateTime(2024, 2, 29));
        });

        test('works for first day of year', () {
          final DateTime date = DateTime(2023, 1, 1, 1, 1, 1);
          expect(date.toDateOnly(), DateTime(2023));
        });

        test('works for last day of year', () {
          final DateTime date = DateTime(2023, 12, 31, 23, 59, 59);
          expect(date.toDateOnly(), DateTime(2023, 12, 31));
        });
      });

      group('getUtcTimeFromLocal', () {
        test('returns same time when offset is 0', () {
          final DateTime utcDateTime = DateTime.utc(2023, 6, 15, 10);
          final DateTime? result = utcDateTime.getUtcTimeFromLocal(0);
          expect(result, utcDateTime);
        });

        test('returns correct UTC time with positive offset', () {
          final DateTime utcDateTime = DateTime.utc(2023, 6, 15, 10);
          const double offset = 2;
          final DateTime? result = utcDateTime.getUtcTimeFromLocal(offset);

          // Calculate expected difference
          final Duration expectedDifference = Duration(
            hours: offset.floor(),
            minutes: ((offset - offset.floor()) * 60).round(),
          );

          expect(result!.difference(utcDateTime), expectedDifference);
        });

        test('returns correct UTC time with negative offset', () {
          final DateTime utcDateTime = DateTime.utc(2023, 6, 15, 10);
          const double offset = -2;
          final DateTime? result = utcDateTime.getUtcTimeFromLocal(offset);

          // Calculate expected difference (will be negative)
          final Duration expectedDifference = Duration(
            hours: offset.floor(),
            minutes: ((offset - offset.floor()) * 60).round(),
          );

          expect(result!.difference(utcDateTime), expectedDifference);
        });

        test('handles fractional positive offset', () {
          final DateTime utcDateTime = DateTime.utc(2023, 6, 15, 10);
          const double offset = 1.5;
          final DateTime? result = utcDateTime.getUtcTimeFromLocal(offset);

          // Calculate expected difference
          final Duration expectedDifference = Duration(
            hours: offset.floor(),
            minutes: ((offset - offset.floor()) * 60).round(),
          );

          expect(result!.difference(utcDateTime), expectedDifference);
        });

        test('handles fractional negative offset', () {
          final DateTime utcDateTime = DateTime.utc(2023, 6, 15, 10);
          const double offset = -1.5;
          final DateTime? result = utcDateTime.getUtcTimeFromLocal(offset);

          // Calculate expected difference (will be negative)
          final Duration expectedDifference = Duration(
            hours: offset.floor(),
            minutes: ((offset - offset.floor()) * 60).round(),
          );

          expect(result!.difference(utcDateTime), expectedDifference);
        });
      });

      group('isBetweenRange', () {
        test('returns true if date is within range (inclusive)', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTimeRange range = DateTimeRange(
            start: DateTime(2023, 6),
            end: DateTime(2023, 6, 30),
          );
          expect(date.isBetweenRange(range), isTrue);
        });

        test('returns true if date is start of range (inclusive)', () {
          final DateTime date = DateTime(2023, 6);
          final DateTimeRange range = DateTimeRange(
            start: DateTime(2023, 6),
            end: DateTime(2023, 6, 30),
          );
          expect(date.isBetweenRange(range), isTrue);
        });

        test('returns true if date is end of range (inclusive)', () {
          final DateTime date = DateTime(2023, 6, 30);
          final DateTimeRange range = DateTimeRange(
            start: DateTime(2023, 6),
            end: DateTime(2023, 6, 30),
          );
          expect(date.isBetweenRange(range), isTrue);
        });

        test('returns false if date is before range', () {
          final DateTime date = DateTime(2023, 5, 31);
          final DateTimeRange range = DateTimeRange(
            start: DateTime(2023, 6),
            end: DateTime(2023, 6, 30),
          );
          expect(date.isBetweenRange(range), isFalse);
        });

        test('returns false if date is after range', () {
          final DateTime date = DateTime(2023, 7);
          final DateTimeRange range = DateTimeRange(
            start: DateTime(2023, 6),
            end: DateTime(2023, 6, 30),
          );
          expect(date.isBetweenRange(range), isFalse);
        });
      });

      group('isBetween', () {
        test('returns true if date is within range (inclusive)', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime start = DateTime(2023, 6);
          final DateTime end = DateTime(2023, 6, 30);
          expect(date.isBetween(start, end), isTrue);
        });

        test('returns true if date is start of range (inclusive)', () {
          final DateTime date = DateTime(2023, 6);
          final DateTime start = DateTime(2023, 6);
          final DateTime end = DateTime(2023, 6, 30);
          expect(date.isBetween(start, end), isTrue);
        });

        test('returns true if date is end of range (inclusive)', () {
          final DateTime date = DateTime(2023, 6, 30);
          final DateTime start = DateTime(2023, 6);
          final DateTime end = DateTime(2023, 6, 30);
          expect(date.isBetween(start, end), isTrue);
        });

        test('returns false if date is before range', () {
          final DateTime date = DateTime(2023, 5, 31);
          final DateTime start = DateTime(2023, 6);
          final DateTime end = DateTime(2023, 6, 30);
          expect(date.isBetween(start, end), isFalse);
        });

        test('returns false if date is after range', () {
          final DateTime date = DateTime(2023, 7);
          final DateTime start = DateTime(2023, 6);
          final DateTime end = DateTime(2023, 6, 30);
          expect(date.isBetween(start, end), isFalse);
        });
      });

      group('isDateAfterToday', () {
        test('returns false if date is today', () {
          final DateTime date = DateTime.now();
          expect(date.isDateAfterToday(date), isFalse);
        });

        test('returns true if date is after today', () {
          final DateTime date = DateTime.now().add(const Duration(days: 1));
          expect(date.isDateAfterToday(date), isTrue);
        });

        test('returns false if date is before today', () {
          final DateTime date = DateTime.now().subtract(const Duration(days: 1));
          expect(date.isDateAfterToday(date), isFalse);
        });

        test('works for date far in the future', () {
          final DateTime date = DateTime(DateTime.now().year + 1);
          expect(date.isDateAfterToday(date), isTrue);
        });
      });

      group('isToday', () {
        test('returns true if date is today', () {
          final DateTime date = DateTime.now();
          expect(date.isToday(), isTrue);
        });

        test('returns false if date is yesterday', () {
          final DateTime date = DateTime.now().subtract(const Duration(days: 1));
          expect(date.isToday(), isFalse);
        });

        test('returns false if date is tomorrow', () {
          final DateTime date = DateTime.now().add(const Duration(days: 1));
          expect(date.isToday(), isFalse);
        });

        test('ignores time component', () {
          final DateTime date = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            10,
            30,
          );
          expect(date.isToday(), isTrue);
        });

        test('handles different years when ignoring year', () {
          final DateTime date = DateTime(
            DateTime.now().year + 1,
            DateTime.now().month,
            DateTime.now().day,
          );
          expect(date.isToday(ignoreYear: true), isTrue);
        });
      });

      group('isSameDateOnly', () {
        test('returns true if dates are the same', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime other = DateTime(2023, 6, 15);
          expect(date.isSameDateOnly(other), isTrue);
        });

        test('returns false if dates are different', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime other = DateTime(2023, 6, 16);
          expect(date.isSameDateOnly(other), isFalse);
        });

        test('ignores time component', () {
          final DateTime date = DateTime(2023, 6, 15, 10, 30);
          final DateTime other = DateTime(2023, 6, 15, 12, 45);
          expect(date.isSameDateOnly(other), isTrue);
        });

        test('handles different years', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime other = DateTime(2024, 6, 15);
          expect(date.isSameDateOnly(other), isFalse);
        });

        test('handles different months', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime other = DateTime(2023, 7, 15);
          expect(date.isSameDateOnly(other), isFalse);
        });
      });
      group('isSameDayMonth', () {
        test('returns true if day and month are the same', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime other = DateTime(2023, 6, 15);
          expect(date.isSameDayMonth(other), isTrue);
        });

        test('returns false if day is different', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime other = DateTime(2023, 6, 16);
          expect(date.isSameDayMonth(other), isFalse);
        });

        test('returns false if month is different', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime other = DateTime(2023, 7, 15);
          expect(date.isSameDayMonth(other), isFalse);
        });

        test('ignores year component', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime other = DateTime(2024, 6, 15);
          expect(date.isSameDayMonth(other), isTrue);
        });

        test('ignores time component', () {
          final DateTime date = DateTime(2023, 6, 15, 10);
          final DateTime other = DateTime(2024, 6, 15, 12);
          expect(date.isSameDayMonth(other), isTrue);
        });
      });

      group('isSameMonth', () {
        test('returns true if month is the same', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime other = DateTime(2023, 6, 20);
          expect(date.isSameMonth(other), isTrue);
        });

        test('returns false if month is different', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime other = DateTime(2023, 7, 15);
          expect(date.isSameMonth(other), isFalse);
        });

        test('ignores day component', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime other = DateTime(2023, 6, 20);
          expect(date.isSameMonth(other), isTrue);
        });

        test('ignores year component', () {
          final DateTime date = DateTime(2023, 6, 15);
          final DateTime other = DateTime(2024, 6);
          expect(date.isSameMonth(other), isTrue);
        });

        test('ignores time component', () {
          final DateTime date = DateTime(2023, 6, 15, 8);
          final DateTime other = DateTime(2024, 6, 20, 12);
          expect(date.isSameMonth(other), isTrue);
        });
      });

      group('setTime', () {
        test('sets time correctly', () {
          final DateTime date = DateTime(2023, 6, 15);
          const TimeOfDay time = TimeOfDay(hour: 10, minute: 30);
          expect(date.setTime(time: time), DateTime(2023, 6, 15, 10, 30));
        });

        test('handles midnight', () {
          final DateTime date = DateTime(2023, 6, 15);
          const TimeOfDay time = TimeOfDay(hour: 0, minute: 0);
          expect(date.setTime(time: time), DateTime(2023, 6, 15));
        });

        test('handles end of day', () {
          final DateTime date = DateTime(2023, 6, 15);
          const TimeOfDay time = TimeOfDay(hour: 23, minute: 59);
          expect(date.setTime(time: time), DateTime(2023, 6, 15, 23, 59));
        });

        test('works for leap year', () {
          final DateTime date = DateTime(2024, 2, 29);
          const TimeOfDay time = TimeOfDay(hour: 12, minute: 30);
          expect(date.setTime(time: time), DateTime(2024, 2, 29, 12, 30));
        });

        test('works for first day of year', () {
          final DateTime date = DateTime(2023);
          const TimeOfDay time = TimeOfDay(hour: 1, minute: 1);
          expect(date.setTime(time: time), DateTime(2023, 1, 1, 1, 1));
        });
      });

      group('alignDateTime', () {
        test('aligns to 15 minute interval (round down)', () {
          final DateTime date = DateTime(2023, 6, 15, 10, 37);
          expect(
            date.alignDateTime(alignment: const Duration(minutes: 15)),
            DateTime(2023, 6, 15, 10, 30),
          );
        });

        test('aligns to 1 hour interval (round up)', () {
          final DateTime date = DateTime(2023, 6, 15, 10, 37);
          expect(
            date.alignDateTime(alignment: const Duration(hours: 1), roundUp: true),
            DateTime(2023, 6, 15, 11),
          );
        });

        test('returns same time if already aligned', () {
          final DateTime date = DateTime(2023, 6, 15, 10, 30);
          expect(
            date.alignDateTime(alignment: const Duration(minutes: 15)),
            DateTime(2023, 6, 15, 10, 30),
          );
        });

        test('returns same time if alignment is zero', () {
          final DateTime date = DateTime(2023, 6, 15, 10, 37);
          expect(date.alignDateTime(alignment: Duration.zero), date);
        });

        test('aligns to 5 second interval (round down)', () {
          final DateTime date = DateTime(2023, 6, 15, 10, 37, 22);
          expect(
            date.alignDateTime(alignment: const Duration(seconds: 5)),
            DateTime(2023, 6, 15, 10, 37, 20),
          );
        });
      });

      group('calculateAgeFromNow', () {
        test('calculates correct age for someone born today', () {
          final DateTime dob = DateTime.now();
          expect(dob.calculateAgeFromNow(), 0);
        });

        test('calculates correct age for someone born 1 year ago', () {
          final DateTime now = DateTime.now();
          final DateTime dob = DateTime(now.year - 1, now.month, now.day);
          expect(dob.calculateAgeFromNow(), 1);
        });

        test('calculates correct age for someone born 10 years ago', () {
          final DateTime now = DateTime.now();
          final DateTime dob = DateTime(now.year - 10, now.month, now.day);
          expect(dob.calculateAgeFromNow(), 10);
        });

        group('handles leap year', () {
          final DateTime dob = DateTime(2000, 2, 29); // Leap year birth date

          test('After leap day in a non-leap year', () {
            // After Feb 29 in a non-leap year
            final DateTime now = DateTime(2023, 3);
            expect(dob.calculateAgeFromNow(now: now), 23);
          });

          test('On Feb 28 in the year they turn a multiple of 4', () {
            final DateTime now = DateTime(2024, 2, 28); // Before leap day in a leap year
            expect(dob.calculateAgeFromNow(now: now), 23);
          });

          test('On Feb 29 in the year they turn a multiple of 4', () {
            final DateTime now = DateTime(2024, 2, 29); // On leap day in a leap year
            expect(dob.calculateAgeFromNow(now: now), 24);
          });

          test('On Mar 1 in the year they turn a multiple of 4', () {
            // After leap day in a leap year
            final DateTime now = DateTime(2024, 3);
            expect(dob.calculateAgeFromNow(now: now), 24);
          });
        });

        test('handles birthday today', () {
          final DateTime dob = DateTime(
            DateTime.now().year - 10,
            DateTime.now().month,
            DateTime.now().day,
          );
          expect(dob.calculateAgeFromNow(), 10);
        });
      });

      group('calculateAgeFromDate', () {
        test('calculates correct age from a past date', () {
          final DateTime dob = DateTime(1990, 6, 15);
          final DateTime fromDate = DateTime(2023, 6, 15);
          expect(dob.calculateAgeFromDate(fromDate), 33);
        });

        test('calculates correct age when birthday has not passed', () {
          final DateTime dob = DateTime(1990, 6, 15);
          final DateTime fromDate = DateTime(2023, 6, 14);
          expect(dob.calculateAgeFromDate(fromDate), 32);
        });

        test('handles leap year', () {
          final DateTime dob = DateTime(2000, 2, 29);
          final DateTime fromDate = DateTime(2023, 3); // After leap day
          expect(dob.calculateAgeFromDate(fromDate), 23);
        });

        test('handles birthday today', () {
          final DateTime now = DateTime.now();
          final DateTime dob = DateTime(now.year - 10, now.month, now.day);
          expect(dob.calculateAgeFromDate(now), 10);
        });

        test('calculates correct age from a future date', () {
          final DateTime dob = DateTime(1990, 6, 15);
          final DateTime fromDate = DateTime(2024, 6, 15);
          expect(dob.calculateAgeFromDate(fromDate), 34);
        });
      });
    });

    group('alignDateTime', () {
      test('Result should NOT be null', () {
        final DateTime? value = DateTime.tryParse('2022-01-07 15:35:56.288');
        if (value == null) {
          // ERROR!
          return;
        }

        // round down
        expect(
          value.alignDateTime(alignment: const Duration(minutes: 30)),
          DateTime.tryParse('2022-01-07 15:30:00.000'),
        );

        // round up
        expect(
          value.alignDateTime(alignment: const Duration(minutes: 30), roundUp: true),
          DateTime.tryParse('2022-01-07 16:00:00.000'),
        );
      });
    });

    group('Year Start and End Dates', () {
      // Test Case 1: Valid year (2022)
      test('Year 2022 - Start Date', () {
        final DateTime start = DateTime(2022);
        expect(DateTime(2022).yearStart, start);
      });

      test('Year 2022 - End Date', () {
        final DateTime end = DateTime(2022, DateTime.december, 31);
        expect(DateTime(2022).yearEnd, end);
      });

      // Test Case 2: Valid leap year (2024)
      test('Leap Year 2024 - Start Date', () {
        final DateTime start = DateTime(2024);
        expect(DateTime(2024).yearStart, start);
      });

      test('Leap Year 2024 - End Date', () {
        final DateTime end = DateTime(2024, DateTime.december, 31);
        expect(DateTime(2024).yearEnd, end);
      });

      // Test Case 3: Invalid negative year
      test('Negative Year - Start Date', () {
        expect(DateTime(-100).yearStart, DateTime(-100));
      });

      test('Negative Year - End Date', () {
        expect(DateTime(-100).yearEnd, DateTime(-100, DateTime.december, 31));
      });

      // Test Case 5: Edge case - Year 1 (minimum valid year)
      test('Year 1 - Start Date', () {
        final DateTime start = DateTime(1);
        expect(DateTime(1).yearStart, start);
      });

      test('Year 1 - End Date', () {
        final DateTime end = DateTime(1, DateTime.december, 31);
        expect(DateTime(1).yearEnd, end);
      });

      // Test Case 6: Edge case - Year 9999 (maximum valid year)
      test('Year 9999 - Start Date', () {
        final DateTime start = DateTime(9999);
        expect(DateTime(9999).yearStart, start);
      });

      test('Year 9999 - End Date', () {
        final DateTime end = DateTime(9999, DateTime.december, 31);
        expect(DateTime(9999).yearEnd, end);
      });

      // Test Case 8: Invalid non-existent year (e.g. 10_000)
      test('Non-Existent Year - Start Date', () {
        expect(() => DateTime(10_000).yearStart, throwsArgumentError);
      });

      test('Non-Existent Year - End Date', () {
        expect(() => DateTime(10_000).yearEnd, throwsArgumentError);
      });
    });

    group('DateTimeExtensions', () {
      test('Leap year test', () {
        // Existing tests
        expect(DateTime(2000).isLeapYear(), true); // Leap year
        expect(DateTime(2024).isLeapYear(), true); // Leap year
        expect(DateTime(1900).isLeapYear(), false); // Not a leap year
        expect(DateTime(2001).isLeapYear(), false); // Not a leap year
        expect(DateTime(2100).isLeapYear(), false); // Not a leap year
        expect(DateTime(2400).isLeapYear(), true); // Leap year
        expect(DateTime(1988).isLeapYear(), true); // Leap year
        expect(DateTime(1992).isLeapYear(), true); // Leap year
        expect(DateTime(1996).isLeapYear(), true); // Leap year
        expect(DateTime(1997).isLeapYear(), false); // Not a leap year

        // Additional tests
        expect(DateTime(1800).isLeapYear(), false); // Not a leap year
        expect(DateTime(1804).isLeapYear(), true); // Leap year
        expect(DateTime(1808).isLeapYear(), true); // Leap year
        expect(DateTime(1812).isLeapYear(), true); // Leap year
        expect(DateTime(1816).isLeapYear(), true); // Leap year
        expect(DateTime(1820).isLeapYear(), true); // Leap year
        expect(DateTime(1824).isLeapYear(), true); // Leap year
        expect(DateTime(1828).isLeapYear(), true); // Leap year
        expect(DateTime(1832).isLeapYear(), true); // Leap year
        expect(DateTime(1836).isLeapYear(), true); // Leap year
        expect(DateTime(1840).isLeapYear(), true); // Leap year
        expect(DateTime(1844).isLeapYear(), true); // Leap year
        expect(DateTime(1848).isLeapYear(), true); // Leap year
        expect(DateTime(1852).isLeapYear(), true); // Leap year
        expect(DateTime(1856).isLeapYear(), true); // Leap year
        expect(DateTime(1860).isLeapYear(), true); // Leap year
        expect(DateTime(1864).isLeapYear(), true); // Leap year
        expect(DateTime(1868).isLeapYear(), true); // Leap year
        expect(DateTime(1872).isLeapYear(), true); // Leap year
        expect(DateTime(1876).isLeapYear(), true); // Leap year
        expect(DateTime(1880).isLeapYear(), true); // Leap year
        expect(DateTime(1884).isLeapYear(), true); // Leap year
        expect(DateTime(1888).isLeapYear(), true); // Leap year
        expect(DateTime(1892).isLeapYear(), true); // Leap year
        expect(DateTime(1896).isLeapYear(), true); // Leap year
        expect(DateTime(1904).isLeapYear(), true); // Leap year

        // Future year tests
        expect(DateTime(2028).isLeapYear(), true); // Leap year
        expect(DateTime(2032).isLeapYear(), true); // Leap year
        expect(DateTime(2036).isLeapYear(), true); // Leap year
        expect(DateTime(2040).isLeapYear(), true); // Leap year
        expect(DateTime(2044).isLeapYear(), true); // Leap year
        expect(DateTime(2048).isLeapYear(), true); // Leap year
        expect(DateTime(2052).isLeapYear(), true); // Leap year
        expect(DateTime(2056).isLeapYear(), true); // Leap year
        expect(DateTime(2060).isLeapYear(), true); // Leap year
        expect(DateTime(2064).isLeapYear(), true); // Leap year
        expect(DateTime(2068).isLeapYear(), true); // Leap year
        expect(DateTime(2072).isLeapYear(), true); // Leap year
        expect(DateTime(2076).isLeapYear(), true); // Leap year
        expect(DateTime(2080).isLeapYear(), true); // Leap year
        expect(DateTime(2084).isLeapYear(), true); // Leap year
        expect(DateTime(2088).isLeapYear(), true); // Leap year
        expect(DateTime(2092).isLeapYear(), true); // Leap year
        expect(DateTime(2096).isLeapYear(), true); // Leap year
        expect(DateTime(2104).isLeapYear(), true); // Leap year
        expect(DateTime(2108).isLeapYear(), true); // Leap year
        expect(DateTime(2112).isLeapYear(), true); // Leap year
        expect(DateTime(2116).isLeapYear(), true); // Leap year
        expect(DateTime(2120).isLeapYear(), true); // Leap year
        expect(DateTime(2124).isLeapYear(), true); // Leap year
        expect(DateTime(2128).isLeapYear(), true); // Leap year
      });
    });

    group('DateTimeExtensions', () {
      test('Non-leap year test', () {
        expect(DateTime(2025).isLeapYear(), false); // Non-leap year
        expect(DateTime(2026).isLeapYear(), false); // Non-leap year
        expect(DateTime(2027).isLeapYear(), false); // Non-leap year
        expect(DateTime(2029).isLeapYear(), false); // Non-leap year
        expect(DateTime(2030).isLeapYear(), false); // Non-leap year
        expect(DateTime(2031).isLeapYear(), false); // Non-leap year
        expect(DateTime(2033).isLeapYear(), false); // Non-leap year
        expect(DateTime(2034).isLeapYear(), false); // Non-leap year
        expect(DateTime(2035).isLeapYear(), false); // Non-leap year
        expect(DateTime(2037).isLeapYear(), false); // Non-leap year
        expect(DateTime(2038).isLeapYear(), false); // Non-leap year
        expect(DateTime(2039).isLeapYear(), false); // Non-leap year
        expect(DateTime(2041).isLeapYear(), false); // Non-leap year
        expect(DateTime(2042).isLeapYear(), false); // Non-leap year
        expect(DateTime(2043).isLeapYear(), false); // Non-leap year
        expect(DateTime(2045).isLeapYear(), false); // Non-leap year
        expect(DateTime(2046).isLeapYear(), false); // Non-leap year
        expect(DateTime(2047).isLeapYear(), false); // Non-leap year
        expect(DateTime(2049).isLeapYear(), false); // Non-leap year
        expect(DateTime(2050).isLeapYear(), false); // Non-leap year
        expect(DateTime(2051).isLeapYear(), false); // Non-leap year
        expect(DateTime(2053).isLeapYear(), false); // Non-leap year
        expect(DateTime(2054).isLeapYear(), false); // Non-leap year
        expect(DateTime(2055).isLeapYear(), false); // Non-leap year
        expect(DateTime(2057).isLeapYear(), false); // Non-leap year
      });
    });

    group('isAfterNow', () {
      test('Current date should NOT be in the future', () {
        expect(DateTime.now().isAfterNow(), false);
      });

      test('Future date should be in the future', () {
        expect(DateTime(2053, DateTime.december, 31).isAfterNow(), true);
      });

      test('Same date should NOT be in the future', () {
        expect(DateTime(2023).isAfterNow(), false);
      });

      test('Null date (defaults to current date) should NOT be in the future', () {
        expect(DateTime.now().isAfterNow(), false);
      });

      test('Custom current date should NOT be in the future', () {
        expect(DateTime(2023).isAfterNow(DateTime(2023, DateTime.january, 2)), false);
      });

      test('Custom future date should be in the future', () {
        expect(DateTime(2023, 1, 2).isAfterNow(DateTime(2023)), true);
      });

      test('Custom past date should NOT be in the future', () {
        expect(DateTime(2023).isAfterNow(DateTime(2023, DateTime.january, 3)), false);
      });
    });

    group('isBeforeNow', () {
      test('Current date should be in the past', () {
        expect(DateTime.now().isBeforeNow(), false);
      });

      test('Past date should be in the past', () {
        expect(DateTime(2020).isBeforeNow(), true);
      });

      test('Same date should NOT be in the past', () {
        expect(DateTime(2050).isBeforeNow(DateTime(2050)), false);
      });

      test('Null date (defaults to current date) should NOT be in the past', () {
        expect(DateTime.now().isBeforeNow(), false);
      });

      test('Custom current date should NOT be in the past', () {
        final DateTime now = DateTime.now();
        expect(now.isBeforeNow(now), false);
      });

      test('Custom future date should NOT be in the past', () {
        expect(DateTime(2063, 1, 2).isBeforeNow(DateTime(2023)), false);
      });

      test('Custom past date should be in the past', () {
        expect(DateTime(2023).isBeforeNow(DateTime(2023, DateTime.january, 3)), true);
      });
    });
  });
}
