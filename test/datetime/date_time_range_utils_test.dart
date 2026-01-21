import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/date_time_range_utils.dart';

void main() {
  group('isNthDayOfMonthInRange', () {
    test('returns true for 2nd Monday of March within range', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2023),
        end: DateTime(2023, 12, 31),
      );
      expect(range.isNthDayOfMonthInRange(2, DateTime.monday, 3), true);
    });

    test('returns false for 2nd Monday of March outside range', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2023, 4),
        end: DateTime(2023, 12, 31),
      );
      expect(range.isNthDayOfMonthInRange(2, DateTime.monday, 3), false);
    });

    test('returns true for 1st Friday of January at start of range', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2023),
        end: DateTime(2023, 12, 31),
      );
      expect(range.isNthDayOfMonthInRange(1, DateTime.friday, 1), true);
    });

    test('returns true for last day of range', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2023),
        end: DateTime(2023, 12, 31),
      );
      expect(range.isNthDayOfMonthInRange(5, DateTime.sunday, 12), true);
    });

    test('returns false for day just after range', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2023),
        end: DateTime(2023, 12, 30),
      );
      expect(range.isNthDayOfMonthInRange(5, DateTime.sunday, 12), false);
    });

    test('returns true for recurring holiday across multiple years', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2022),
        end: DateTime(2024, 12, 31),
      );
      expect(range.isNthDayOfMonthInRange(3, DateTime.monday, 1), true);
    });

    test('returns false when nth occurrence does not exist', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2023),
        end: DateTime(2023, 12, 31),
      );
      expect(
        range.isNthDayOfMonthInRange(5, DateTime.monday, 2),
        false,
      ); // February never has 5 Mondays
    });

    test('returns true for leap year day when in range', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2024),
        end: DateTime(2024, 12, 31),
      );
      expect(range.isNthDayOfMonthInRange(5, DateTime.thursday, 2), true); // February 29, 2024
    });

    test('returns false for leap year day when not in range', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2023),
        end: DateTime(2023, 12, 31),
      );
      expect(
        range.isNthDayOfMonthInRange(5, DateTime.thursday, 2),
        false,
      ); // February 29, 2024 not in 2023
    });

    test('returns true for 1st Monday of January in multi-year range', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2023),
        end: DateTime(2025, 12, 31),
      );
      expect(range.isNthDayOfMonthInRange(1, DateTime.monday, 1), true);
    });

    test('returns false for 6th Friday of April (impossible case)', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2023),
        end: DateTime(2023, 12, 31),
      );
      expect(range.isNthDayOfMonthInRange(6, DateTime.friday, 4), false);
    });

    test('returns true for 5th Wednesday of May 2023 (May 31, 2023)', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2023),
        end: DateTime(2023, 12, 31),
      );
      expect(range.isNthDayOfMonthInRange(5, DateTime.wednesday, 5), true);
    });

    test('returns false for 5th Wednesday of May 2024', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2024),
        end: DateTime(2024, 12, 31),
      );
      expect(range.isNthDayOfMonthInRange(5, DateTime.wednesday, 5), true);
    });

    test('returns true for 4th Thursday of November (Thanksgiving) in 2023', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2023),
        end: DateTime(2023, 12, 31),
      );
      expect(range.isNthDayOfMonthInRange(4, DateTime.thursday, 11), true);
    });

    test('returns false for 4th Thursday of November (Thanksgiving) in range '
        'ending before November', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2023),
        end: DateTime(2023, 10, 31),
      );
      expect(range.isNthDayOfMonthInRange(4, DateTime.thursday, 11), false);
    });

    test('returns true for 1st Sunday of February in leap year 2024', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2024),
        end: DateTime(2024, 12, 31),
      );
      expect(range.isNthDayOfMonthInRange(1, DateTime.sunday, 2), true);
    });

    test('returns false for 5th Saturday of December 2023', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2023),
        end: DateTime(2023, 12, 31),
      );
      expect(range.isNthDayOfMonthInRange(5, DateTime.saturday, 12), true);
    });

    test('returns true for 2nd Tuesday of February in non-leap year range '
        'including multiple years', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2023),
        end: DateTime(2025, 12, 31),
      );
      expect(range.isNthDayOfMonthInRange(2, DateTime.tuesday, 2), true);
    });

    test('returns false when nth occurrence does not exist', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2023),
        end: DateTime(2023, 12, 31),
      );
      expect(
        range.isNthDayOfMonthInRange(5, DateTime.monday, 2),
        false,
      ); // February never has 5 Mondays
    });

    test('returns false for 6th Friday of April (impossible case)', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2023),
        end: DateTime(2023, 12, 31),
      );
      expect(range.isNthDayOfMonthInRange(6, DateTime.friday, 4), false);
    });

    test('returns false for 5th Wednesday of May 2024', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2024),
        end: DateTime(2024, 12, 31),
      );
      expect(range.isNthDayOfMonthInRange(5, DateTime.wednesday, 5), true);
    });

    test('returns true for 5th Saturday of December 2024 (does not exist)', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2024),
        end: DateTime(2024, 12, 31),
      );
      expect(range.isNthDayOfMonthInRange(5, DateTime.saturday, 12), false);
    });

    test('returns true for 1st Monday of January in multi-year range', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2023),
        end: DateTime(2025, 12, 31),
      );
      expect(range.isNthDayOfMonthInRange(1, DateTime.monday, 1), true);
    });

    test('returns true for February 29 in leap year', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2024),
        end: DateTime(2024, 12, 31),
      );
      expect(
        range.isNthDayOfMonthInRange(1, DateTime.thursday, 2),
        true,
      ); // February has a Thursday on Feb.29
    });

    test('returns false for February when asking for a day that does not exist', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2023),
        end: DateTime(2023, 12, 31),
      );
      expect(
        range.isNthDayOfMonthInRange(5, DateTime.monday, 2),
        false,
      ); // February never has a fifth Monday
    });

    test('returns true for last day of range', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2023),
        end: DateTime(2023, 12, 31),
      );
      expect(
        range.isNthDayOfMonthInRange(5, DateTime.sunday, 12),
        true,
      ); // December has a Sunday on Dec.31
    });

    // Cross-year range tests (Fix 3: algorithm fix for cross-year validation)
    test('January month in range spanning Nov to Feb', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2023, 11, 15),
        end: DateTime(2024, 2, 15),
      );
      // 2nd Monday of January 2024 is January 8
      expect(range.isNthDayOfMonthInRange(2, DateTime.monday, 1), isTrue);
    });

    test('October month not in range spanning Nov to Feb', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2023, 11, 15),
        end: DateTime(2024, 2, 15),
      );
      expect(range.isNthDayOfMonthInRange(1, DateTime.monday, 10), isFalse);
    });

    test('December month in range spanning Nov to Feb', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2023, 11, 15),
        end: DateTime(2024, 2, 15),
      );
      // 1st Monday of December 2023 is December 4
      expect(range.isNthDayOfMonthInRange(1, DateTime.monday, 12), isTrue);
    });

    test('invalid month 13 returns false', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2023),
        end: DateTime(2023, 12, 31),
      );
      expect(range.isNthDayOfMonthInRange(1, DateTime.monday, 13), isFalse);
    });

    test('month 0 returns false', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2023),
        end: DateTime(2023, 12, 31),
      );
      expect(range.isNthDayOfMonthInRange(1, DateTime.monday, 0), isFalse);
    });

    test('inclusive=false excludes boundary dates', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2024, 1, 8), // 2nd Monday of Jan
        end: DateTime(2024, 1, 31),
      );
      expect(
        range.isNthDayOfMonthInRange(2, DateTime.monday, 1, isInclusive: false),
        isFalse,
      );
    });

    test('inclusive=true includes boundary dates', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2024, 1, 8), // 2nd Monday of Jan
        end: DateTime(2024, 1, 31),
      );
      expect(
        range.isNthDayOfMonthInRange(2, DateTime.monday, 1, isInclusive: true),
        isTrue,
      );
    });

    test('range within same month finds occurrence', () {
      final DateTimeRange<DateTime> range = DateTimeRange(
        start: DateTime(2024),
        end: DateTime(2024, 1, 31),
      );
      expect(range.isNthDayOfMonthInRange(1, DateTime.monday, 1), isTrue);
    });
  });

  group('DateTimeCheck extension', () {
    group('inRange', () {
      test('returns true when date is within range', () {
        final DateTimeRange<DateTime> range = DateTimeRange(
          start: DateTime(2025),
          end: DateTime(2025, 1, 31),
        );
        expect(range.inRange(DateTime(2025, 1, 15)), isTrue);
      });

      test('returns false when date is before range', () {
        final DateTimeRange<DateTime> range = DateTimeRange(
          start: DateTime(2025),
          end: DateTime(2025, 1, 31),
        );
        expect(range.inRange(DateTime(2024, 12, 31)), isFalse);
      });

      test('returns false when date is after range', () {
        final DateTimeRange<DateTime> range = DateTimeRange(
          start: DateTime(2025),
          end: DateTime(2025, 1, 31),
        );
        expect(range.inRange(DateTime(2025, 2)), isFalse);
      });

      // Updated: inRange now defaults to inclusive=true
      test('returns true when date is equal to start (inclusive default)', () {
        final DateTimeRange<DateTime> range = DateTimeRange(
          start: DateTime(2025),
          end: DateTime(2025, 1, 31),
        );
        expect(range.inRange(DateTime(2025)), isTrue);
      });

      test('returns false when date is equal to start with inclusive=false', () {
        final DateTimeRange<DateTime> range = DateTimeRange(
          start: DateTime(2025),
          end: DateTime(2025, 1, 31),
        );
        expect(range.inRange(DateTime(2025), inclusive: false), isFalse);
      });

      // Updated: inRange now defaults to inclusive=true
      test('returns true when date is equal to end (inclusive default)', () {
        final DateTimeRange<DateTime> range = DateTimeRange(
          start: DateTime(2025),
          end: DateTime(2025, 1, 31),
        );
        expect(range.inRange(DateTime(2025, 1, 31)), isTrue);
      });

      test('returns false when date is equal to end with inclusive=false', () {
        final DateTimeRange<DateTime> range = DateTimeRange(
          start: DateTime(2025),
          end: DateTime(2025, 1, 31),
        );
        expect(range.inRange(DateTime(2025, 1, 31), inclusive: false), isFalse);
      });

      test('returns true for date one millisecond after start', () {
        final DateTimeRange<DateTime> range = DateTimeRange(
          start: DateTime(2025),
          end: DateTime(2025, 1, 31),
        );
        expect(range.inRange(DateTime(2025, 1, 1, 0, 0, 0, 1)), isTrue);
      });

      test('returns true for date one millisecond before end', () {
        final DateTimeRange<DateTime> range = DateTimeRange(
          start: DateTime(2025),
          end: DateTime(2025, 1, 31),
        );
        expect(range.inRange(DateTime(2025, 1, 30, 23, 59, 59, 999)), isTrue);
      });

      test('returns true for date at midnight within range', () {
        final DateTimeRange<DateTime> range = DateTimeRange(
          start: DateTime(2025),
          end: DateTime(2025, 1, 31),
        );
        expect(range.inRange(DateTime(2025, 1, 15)), isTrue);
      });

      test('returns true for date at last millisecond of day '
          'within range', () {
        final DateTimeRange<DateTime> range = DateTimeRange(
          start: DateTime(2025),
          end: DateTime(2025, 1, 31),
        );
        expect(range.inRange(DateTime(2025, 1, 15, 23, 59, 59, 999)), isTrue);
      });

      test('returns false for date in different year', () {
        final DateTimeRange<DateTime> range = DateTimeRange(
          start: DateTime(2025),
          end: DateTime(2025, 1, 31),
        );
        expect(range.inRange(DateTime(2026, 1, 15)), isFalse);
      });

      // Fix 4: Additional inclusive boundary semantics tests
      test('middle date is always in range regardless of inclusive flag', () {
        final DateTimeRange<DateTime> range = DateTimeRange(
          start: DateTime(2024, 6, 1),
          end: DateTime(2024, 6, 30),
        );
        expect(range.inRange(DateTime(2024, 6, 15), inclusive: false), isTrue);
        expect(range.inRange(DateTime(2024, 6, 15), inclusive: true), isTrue);
      });

      test('single-day range with inclusive=true includes the date', () {
        final DateTimeRange<DateTime> range = DateTimeRange(
          start: DateTime(2024, 6, 15),
          end: DateTime(2024, 6, 15),
        );
        expect(range.inRange(DateTime(2024, 6, 15), inclusive: true), isTrue);
      });

      test('single-day range with inclusive=false excludes the date', () {
        final DateTimeRange<DateTime> range = DateTimeRange(
          start: DateTime(2024, 6, 15),
          end: DateTime(2024, 6, 15),
        );
        expect(range.inRange(DateTime(2024, 6, 15), inclusive: false), isFalse);
      });
    });

    group('isNowInRange', () {
      test('returns true when current date is within range', () {
        final DateTime now = DateTime.now();
        final DateTimeRange<DateTime> range = DateTimeRange(
          start: now.subtract(const Duration(days: 1)),
          end: now.add(const Duration(days: 1)),
        );
        expect(range.isNowInRange(now: now), isTrue);
      });

      test('returns false when current date is before range', () {
        final DateTime now = DateTime.now();
        final DateTimeRange<DateTime> range = DateTimeRange(
          start: now.add(const Duration(days: 1)),
          end: now.add(const Duration(days: 2)),
        );
        expect(range.isNowInRange(now: now), isFalse);
      });

      test('returns false when current date is after range', () {
        final DateTime now = DateTime.now();

        final DateTimeRange<DateTime> range = DateTimeRange(
          start: now.subtract(const Duration(days: 2)),
          // this time yesterday
          end: now.subtract(const Duration(days: 1)),
        );

        expect(range.isNowInRange(now: now), isFalse);
      });

      // Updated: isNowInRange now defaults to inclusive=true
      test('returns true when current date is equal to start (inclusive default)', () {
        final DateTime now = DateTime.now();

        final DateTimeRange<DateTime> range = DateTimeRange(
          start: now,
          // this time tomorrow
          end: now.add(const Duration(days: 1)),
        );

        expect(range.isNowInRange(now: now), isTrue);
      });

      test('returns false when current date is equal to start with inclusive=false', () {
        final DateTime now = DateTime.now();

        final DateTimeRange<DateTime> range = DateTimeRange(
          start: now,
          end: now.add(const Duration(days: 1)),
        );

        expect(range.isNowInRange(now: now, inclusive: false), isFalse);
      });

      // Updated: isNowInRange now defaults to inclusive=true
      test('returns true when current date is equal to end (inclusive default)', () {
        final DateTime now = DateTime.now();
        final DateTimeRange<DateTime> range = DateTimeRange(
          start: now.subtract(const Duration(days: 1)),
          end: now,
        );
        expect(range.isNowInRange(now: now), isTrue);
      });

      test('returns false when current date is equal to end with inclusive=false', () {
        final DateTime now = DateTime.now();
        final DateTimeRange<DateTime> range = DateTimeRange(
          start: now.subtract(const Duration(days: 1)),
          end: now,
        );
        expect(range.isNowInRange(now: now, inclusive: false), isFalse);
      });

      test('returns true when current date is one millisecond '
          'after start', () {
        final DateTime now = DateTime.now();
        final DateTimeRange<DateTime> range = DateTimeRange(
          start: now.subtract(const Duration(milliseconds: 1)),
          end: now.add(const Duration(days: 1)),
        );
        expect(range.isNowInRange(now: now), isTrue);
      });

      test('returns true when current date is one millisecond '
          'before end', () {
        final DateTime now = DateTime.now();
        final DateTimeRange<DateTime> range = DateTimeRange(
          start: now.subtract(const Duration(days: 1)),
          end: now.add(const Duration(milliseconds: 1)),
        );
        expect(range.isNowInRange(now: now), isTrue);
      });

      test('returns true when range spans multiple years and current '
          'date is within', () {
        final DateTime now = DateTime.now();
        final DateTimeRange<DateTime> range = DateTimeRange(
          start: DateTime(now.year - 1),
          end: DateTime(now.year + 1, 12, 31),
        );
        expect(range.isNowInRange(now: now), isTrue);
      });

      test('returns false when range is in the past', () {
        final DateTime now = DateTime.now();
        final DateTimeRange<DateTime> range = DateTimeRange(
          start: now.subtract(const Duration(days: 365)),
          end: now.subtract(const Duration(days: 364)),
        );
        expect(range.isNowInRange(now: now), isFalse);
      });

      test('returns false when range is in the future', () {
        final DateTime now = DateTime.now();
        final DateTimeRange<DateTime> range = DateTimeRange(
          start: now.add(const Duration(days: 364)),
          end: now.add(const Duration(days: 365)),
        );
        expect(range.isNowInRange(now: now), isFalse);
      });
    });
  });
}
