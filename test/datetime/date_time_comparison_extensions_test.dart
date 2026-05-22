// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/date_time_comparison_extensions.dart';

void main() {
  group('DateTimeComparisonExtensions', () {
    group('isAfterNow', () {
      test('true when after the provided now', () {
        expect(DateTime(2023, 6, 16).isAfterNow(DateTime(2023, 6, 15)), isTrue);
      });

      test('false when before the provided now', () {
        expect(DateTime(2023, 6, 14).isAfterNow(DateTime(2023, 6, 15)), isFalse);
      });

      test('false when equal to the provided now', () {
        final DateTime d = DateTime(2023, 6, 15);
        expect(d.isAfterNow(d), isFalse);
      });
    });

    group('isBeforeNow', () {
      test('true when before the provided now', () {
        expect(DateTime(2023, 6, 14).isBeforeNow(DateTime(2023, 6, 15)), isTrue);
      });

      test('false when after the provided now', () {
        expect(DateTime(2023, 6, 16).isBeforeNow(DateTime(2023, 6, 15)), isFalse);
      });
    });

    group('isBeforeNullable', () {
      test('false when other is null', () {
        expect(DateTime(2023, 6, 15).isBeforeNullable(null), isFalse);
      });

      test('true when this is before other', () {
        expect(DateTime(2023, 6, 14).isBeforeNullable(DateTime(2023, 6, 15)), isTrue);
      });

      test('false when this is after other', () {
        expect(DateTime(2023, 6, 16).isBeforeNullable(DateTime(2023, 6, 15)), isFalse);
      });
    });

    group('isAfterNullable', () {
      test('false when other is null', () {
        expect(DateTime(2023, 6, 15).isAfterNullable(null), isFalse);
      });

      test('true when this is after other', () {
        expect(DateTime(2023, 6, 16).isAfterNullable(DateTime(2023, 6, 15)), isTrue);
      });

      test('false when this is before other', () {
        expect(DateTime(2023, 6, 14).isAfterNullable(DateTime(2023, 6, 15)), isFalse);
      });
    });

    group('isYearCurrent', () {
      test('true when years match', () {
        expect(DateTime(2023, 1, 1).isYearCurrent(now: DateTime(2023, 12, 31)), isTrue);
      });

      test('false when years differ', () {
        expect(DateTime(2022, 1, 1).isYearCurrent(now: DateTime(2023, 1, 1)), isFalse);
      });
    });

    group('isSameDateOrAfter', () {
      test('true on the same date ignoring time', () {
        expect(
          DateTime(2023, 6, 15, 1).isSameDateOrAfter(DateTime(2023, 6, 15, 23)),
          isTrue,
        );
      });

      test('true when strictly after', () {
        expect(DateTime(2023, 6, 16).isSameDateOrAfter(DateTime(2023, 6, 15)), isTrue);
      });

      test('false when before', () {
        expect(DateTime(2023, 6, 14).isSameDateOrAfter(DateTime(2023, 6, 15)), isFalse);
      });
    });

    group('isSameDateOrBefore', () {
      test('true on the same date ignoring time', () {
        expect(
          DateTime(2023, 6, 15, 23).isSameDateOrBefore(DateTime(2023, 6, 15, 1)),
          isTrue,
        );
      });

      test('true when strictly before', () {
        expect(DateTime(2023, 6, 14).isSameDateOrBefore(DateTime(2023, 6, 15)), isTrue);
      });

      test('false when after', () {
        expect(DateTime(2023, 6, 16).isSameDateOrBefore(DateTime(2023, 6, 15)), isFalse);
      });
    });

    group('toDateOnly', () {
      test('strips the time component', () {
        expect(DateTime(2023, 6, 15, 14, 30, 45).toDateOnly(), DateTime(2023, 6, 15));
      });
    });

    group('isBetween', () {
      test('inclusive includes the start boundary', () {
        final DateTime start = DateTime(2023, 6, 1);
        final DateTime end = DateTime(2023, 6, 30);
        expect(start.isBetween(start, end), isTrue);
      });

      test('inclusive includes the end boundary', () {
        final DateTime start = DateTime(2023, 6, 1);
        final DateTime end = DateTime(2023, 6, 30);
        expect(end.isBetween(start, end), isTrue);
      });

      test('true for a date strictly inside', () {
        expect(
          DateTime(2023, 6, 15).isBetween(DateTime(2023, 6, 1), DateTime(2023, 6, 30)),
          isTrue,
        );
      });

      test('exclusive excludes the start boundary', () {
        final DateTime start = DateTime(2023, 6, 1);
        final DateTime end = DateTime(2023, 6, 30);
        expect(start.isBetween(start, end, isInclusive: false), isFalse);
      });

      test('false for a date outside the range', () {
        expect(
          DateTime(2023, 7, 1).isBetween(DateTime(2023, 6, 1), DateTime(2023, 6, 30)),
          isFalse,
        );
      });
    });

    group('isBetweenRange', () {
      test('false when range is null', () {
        expect(DateTime(2023, 6, 15).isBetweenRange(null), isFalse);
      });

      test('true when inside the range', () {
        final DateTimeRange range = DateTimeRange(
          start: DateTime(2023, 6, 1),
          end: DateTime(2023, 6, 30),
        );
        expect(DateTime(2023, 6, 15).isBetweenRange(range), isTrue);
      });

      test('exclusive excludes the start boundary', () {
        final DateTimeRange range = DateTimeRange(
          start: DateTime(2023, 6, 1),
          end: DateTime(2023, 6, 30),
        );
        expect(DateTime(2023, 6, 1).isBetweenRange(range, isInclusive: false), isFalse);
      });
    });

    group('isAnnualDateInRange', () {
      test('true when range is null', () {
        expect(DateTime(2023, 6, 15).isAnnualDateInRange(null), isTrue);
      });

      test('with explicit year uses range membership', () {
        final DateTimeRange range = DateTimeRange(
          start: DateTime(2023, 6, 1),
          end: DateTime(2023, 6, 30),
        );
        expect(DateTime(2023, 6, 15).isAnnualDateInRange(range), isTrue);
      });

      test('year 0 matches month/day within a single-year range', () {
        final DateTimeRange range = DateTimeRange(
          start: DateTime(2023, 6, 1),
          end: DateTime(2023, 6, 30),
        );
        expect(DateTime(0, 6, 15).isAnnualDateInRange(range), isTrue);
      });

      test('year 0 false when month/day outside a single-year range', () {
        final DateTimeRange range = DateTimeRange(
          start: DateTime(2023, 6, 1),
          end: DateTime(2023, 6, 30),
        );
        expect(DateTime(0, 8, 15).isAnnualDateInRange(range), isFalse);
      });

      test('year 0 matches across a year-spanning range', () {
        final DateTimeRange range = DateTimeRange(
          start: DateTime(2023, 12, 1),
          end: DateTime(2024, 2, 28),
        );
        expect(DateTime(0, 1, 15).isAnnualDateInRange(range), isTrue);
      });
    });

    group('isDateAfterToday', () {
      test('true for tomorrow relative to now', () {
        expect(DateTime(2023, 6, 16).isDateAfterToday(now: DateTime(2023, 6, 15, 10)), isTrue);
      });

      test('false for later today', () {
        expect(DateTime(2023, 6, 15, 23).isDateAfterToday(now: DateTime(2023, 6, 15, 10)), isFalse);
      });

      test('false for yesterday', () {
        expect(DateTime(2023, 6, 14).isDateAfterToday(now: DateTime(2023, 6, 15, 10)), isFalse);
      });
    });

    group('isToday', () {
      test('true when same year, month, day', () {
        expect(DateTime(2023, 6, 15, 8).isToday(now: DateTime(2023, 6, 15, 20)), isTrue);
      });

      test('false for a different day', () {
        expect(DateTime(2023, 6, 14).isToday(now: DateTime(2023, 6, 15)), isFalse);
      });

      test('ignoreYear matches same month/day in a different year', () {
        expect(
          DateTime(2020, 6, 15).isToday(now: DateTime(2023, 6, 15), ignoreYear: true),
          isTrue,
        );
      });

      test('without ignoreYear different year is false', () {
        expect(DateTime(2020, 6, 15).isToday(now: DateTime(2023, 6, 15)), isFalse);
      });
    });

    group('isSameDateOnly', () {
      test('true when y/m/d all match regardless of time', () {
        expect(
          DateTime(2023, 6, 15, 1).isSameDateOnly(DateTime(2023, 6, 15, 23)),
          isTrue,
        );
      });

      test('false when day differs', () {
        expect(DateTime(2023, 6, 15).isSameDateOnly(DateTime(2023, 6, 16)), isFalse);
      });
    });

    group('isSameDayMonth', () {
      test('true when month and day match across years', () {
        expect(DateTime(2020, 6, 15).isSameDayMonth(DateTime(2023, 6, 15)), isTrue);
      });

      test('false when day differs', () {
        expect(DateTime(2023, 6, 15).isSameDayMonth(DateTime(2023, 6, 16)), isFalse);
      });
    });

    group('isSameMonth', () {
      test('true when month matches across years', () {
        expect(DateTime(2020, 6, 1).isSameMonth(DateTime(2023, 6, 30)), isTrue);
      });

      test('false when month differs', () {
        expect(DateTime(2023, 6, 1).isSameMonth(DateTime(2023, 7, 1)), isFalse);
      });
    });
  });
}
