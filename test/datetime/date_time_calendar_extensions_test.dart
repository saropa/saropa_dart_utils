// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/date_time_calendar_extensions.dart';

void main() {
  group('DateTimeCalendarExtensions', () {
    group('calculateAgeFromDate', () {
      test('birthday already passed this year', () {
        final DateTime dob = DateTime(1990, 6, 15);
        expect(dob.calculateAgeFromDate(DateTime(2023, 8, 1)), 33);
      });

      test('birthday not yet reached this year', () {
        final DateTime dob = DateTime(1990, 6, 15);
        expect(dob.calculateAgeFromDate(DateTime(2023, 3, 1)), 32);
      });

      test('exactly on the birthday', () {
        final DateTime dob = DateTime(1990, 6, 15);
        expect(dob.calculateAgeFromDate(DateTime(2023, 6, 15)), 33);
      });

      test('day before the birthday', () {
        final DateTime dob = DateTime(1990, 6, 15);
        expect(dob.calculateAgeFromDate(DateTime(2023, 6, 14)), 32);
      });

      test('same calendar year as birth returns 0', () {
        final DateTime dob = DateTime(2023, 1, 1);
        expect(dob.calculateAgeFromDate(DateTime(2023, 12, 31)), 0);
      });
    });

    group('calculateAgeFromNow', () {
      test('uses provided now override', () {
        final DateTime dob = DateTime(1990, 6, 15);
        expect(dob.calculateAgeFromNow(now: DateTime(2023, 8, 1)), 33);
      });
    });

    group('mostRecentWeekday', () {
      test('returns same date when it is already the target weekday', () {
        // 2023-06-15 is a Thursday.
        final DateTime thursday = DateTime(2023, 6, 15);
        expect(thursday.mostRecentWeekday(DateTime.thursday), DateTime(2023, 6, 15));
      });

      test('returns previous Monday from a Thursday', () {
        final DateTime thursday = DateTime(2023, 6, 15);
        expect(thursday.mostRecentWeekday(DateTime.monday), DateTime(2023, 6, 12));
      });

      test('returns previous Sunday from a Thursday', () {
        final DateTime thursday = DateTime(2023, 6, 15);
        expect(thursday.mostRecentWeekday(DateTime.sunday), DateTime(2023, 6, 11));
      });
    });

    group('mostRecentSunday', () {
      test('returns the Sunday on or before this date', () {
        // 2023-06-15 is a Thursday; preceding Sunday is 2023-06-11.
        expect(DateTime(2023, 6, 15).mostRecentSunday, DateTime(2023, 6, 11));
      });

      test('returns same date when it is already Sunday', () {
        // 2023-06-11 is a Sunday.
        expect(DateTime(2023, 6, 11).mostRecentSunday, DateTime(2023, 6, 11));
      });
    });

    group('dayOfYear', () {
      test('January 1 is day 1', () {
        expect(DateTime(2023).dayOfYear, 1);
      });

      test('December 31 in a non-leap year is day 365', () {
        expect(DateTime(2023, 12, 31).dayOfYear, 365);
      });

      test('December 31 in a leap year is day 366', () {
        expect(DateTime(2024, 12, 31).dayOfYear, 366);
      });

      test('March 1 in a leap year is day 61', () {
        expect(DateTime(2024, 3, 1).dayOfYear, 61);
      });
    });

    group('numOfWeeks', () {
      test('returns 52 for a normal year', () {
        expect(DateTime(2023).numOfWeeks(2023), 52);
      });

      test('returns 53 for a long year', () {
        // 2020 is an ISO 53-week year.
        expect(DateTime(2020).numOfWeeks(2020), 53);
      });
    });

    group('weekNumber', () {
      test('Jan 1 2023 belongs to last week of 2022 (ISO)', () {
        // 2023-01-01 is a Sunday in ISO week 52 of 2022.
        expect(DateTime(2023).weekNumber(), 52);
      });

      test('mid-year week number', () {
        // 2023-06-15 falls in ISO week 24.
        expect(DateTime(2023, 6, 15).weekNumber(), 24);
      });

      test('first week of January', () {
        // 2023-01-02 (Monday) is ISO week 1 of 2023.
        expect(DateTime(2023, 1, 2).weekNumber(), 1);
      });
    });

    group('toSerialString', () {
      test('formats date and time with T separator', () {
        expect(DateTime(2023, 6, 15, 9, 5, 3).toSerialString, '20230615T090503');
      });

      test('pads single-digit components', () {
        expect(DateTime(2023, 1, 2, 1, 2, 3).toSerialString, '20230102T010203');
      });
    });

    group('toSerialStringDay', () {
      test('formats date only', () {
        expect(DateTime(2023, 6, 15).toSerialStringDay, '20230615');
      });

      test('pads single-digit month and day', () {
        expect(DateTime(2023, 1, 2).toSerialStringDay, '20230102');
      });
    });

    group('getUtcTimeFromLocal', () {
      test('returns same instance for zero offset', () {
        final DateTime d = DateTime(2023, 6, 15, 12);
        expect(d.getUtcTimeFromLocal(0), same(d));
      });

      test('subtracts positive whole-hour offset (UTC+2)', () {
        expect(DateTime(2023, 6, 15, 12).getUtcTimeFromLocal(2), DateTime(2023, 6, 15, 10));
      });

      test('adds for negative offset (UTC-5)', () {
        expect(DateTime(2023, 6, 15, 12).getUtcTimeFromLocal(-5), DateTime(2023, 6, 15, 17));
      });

      test('handles fractional offset (UTC+5:30)', () {
        expect(
          DateTime(2023, 6, 15, 12).getUtcTimeFromLocal(5.5),
          DateTime(2023, 6, 15, 6, 30),
        );
      });
    });

    group('setTime', () {
      test('replaces time keeping the date', () {
        final DateTime d = DateTime(2023, 6, 15, 9, 5, 30);
        expect(
          d.setTime(time: const TimeOfDay(hour: 14, minute: 45)),
          DateTime(2023, 6, 15, 14, 45),
        );
      });

      test('drops seconds from the original', () {
        final DateTime d = DateTime(2023, 6, 15, 9, 5, 30);
        expect(d.setTime(time: const TimeOfDay(hour: 0, minute: 0)), DateTime(2023, 6, 15));
      });
    });

    group('alignDateTime', () {
      test('returns same instance for zero alignment', () {
        final DateTime d = DateTime(2023, 6, 15, 12, 37);
        expect(d.alignDateTime(alignment: Duration.zero), same(d));
      });

      test('rounds down to 15-minute boundary', () {
        expect(
          DateTime(2023, 6, 15, 12, 37).alignDateTime(alignment: const Duration(minutes: 15)),
          DateTime(2023, 6, 15, 12, 30),
        );
      });

      test('rounds up to next 15-minute boundary', () {
        expect(
          DateTime(2023, 6, 15, 12, 37).alignDateTime(
            alignment: const Duration(minutes: 15),
            shouldRoundUp: true,
          ),
          DateTime(2023, 6, 15, 12, 45),
        );
      });

      test('already aligned returns same instance', () {
        final DateTime d = DateTime(2023, 6, 15, 12, 30);
        expect(d.alignDateTime(alignment: const Duration(minutes: 15)), same(d));
      });

      test('aligns down to the hour', () {
        expect(
          DateTime(2023, 6, 15, 12, 37, 20).alignDateTime(alignment: const Duration(hours: 1)),
          DateTime(2023, 6, 15, 12),
        );
      });
    });
  });
}
