import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';
// isAnnualDateInRange is the documented consumer of toAnnualDate's year-0
// output; imported so the round-trip contract can be tested end to end.
import 'package:saropa_dart_utils/datetime/date_time_bounds_extensions.dart';
import 'package:saropa_dart_utils/datetime/date_time_comparison_extensions.dart';

void main() {
  group('startOfDay', () {
    test('strips time', () {
      final DateTime d = DateTime(2024, 6, 15, 14, 30);
      expect(d.startOfDay, DateTime(2024, 6, 15));
    });
  });
  group('endOfDay', () {
    test('last moment of day', () {
      final DateTime d = DateTime(2024, 6, 15);
      expect(d.endOfDay, DateTime(2024, 6, 15, 23, 59, 59, 999, 999));
    });
  });
  group('quarter', () {
    test('Q1–Q4', () {
      expect(DateTime(2024, 1, 1).quarter, 1);
      expect(DateTime(2024, 4, 1).quarter, 2);
      expect(DateTime(2024, 7, 1).quarter, 3);
      expect(DateTime(2024, 10, 1).quarter, 4);
    });
  });
  group('isWeekend', () {
    test('Saturday and Sunday', () {
      expect(DateTime(2024, 6, 15).isWeekend, isTrue); // Sat
      expect(DateTime(2024, 6, 16).isWeekend, isTrue); // Sun
      expect(DateTime(2024, 6, 17).isWeekend, isFalse);
    });
  });
  group('nextWeekday', () {
    test('skips to Monday from Saturday', () {
      final DateTime sat = DateTime(2024, 6, 15);
      expect(sat.nextWeekday(), DateTime(2024, 6, 17));
    });
  });
  group('startOfMonth endOfMonth', () {
    test('bounds', () {
      final DateTime d = DateTime(2024, 6, 15);
      expect(d.startOfMonth, DateTime(2024, 6));
      expect(d.endOfMonth.day, 30);
    });
  });

  group('toAnnualDate', () {
    test('should return date with year 0 preserving month and day', () {
      final DateTime annual = DateTime(2024, 3, 15).toAnnualDate;
      expect(annual.year, 0);
      expect(annual.month, 3);
      expect(annual.day, 15);
    });

    test('should keep Feb 29 without rolling over (year 0 is a leap year)', () {
      final DateTime annual = DateTime(2024, 2, 29).toAnnualDate;
      expect(annual.year, 0);
      expect(annual.month, 2);
      expect(annual.day, 29);
    });

    test('should preserve Jan 1 exactly', () {
      final DateTime annual = DateTime(2024, 1, 1).toAnnualDate;
      expect(annual, DateTime(0, 1, 1));
    });

    test('should preserve Dec 31 exactly', () {
      final DateTime annual = DateTime(2024, 12, 31).toAnnualDate;
      expect(annual, DateTime(0, 12, 31));
    });

    test('should drop all time-of-day components', () {
      final DateTime annual = DateTime(2024, 3, 15, 23, 59, 59, 999, 999).toAnnualDate;
      expect(annual.hour, 0);
      expect(annual.minute, 0);
      expect(annual.second, 0);
      expect(annual.millisecond, 0);
      expect(annual.microsecond, 0);
    });

    test('should be idempotent for a value already at year 0', () {
      final DateTime once = DateTime(2024, 3, 15).toAnnualDate;
      expect(once.toAnnualDate, once);
    });

    test('should produce equal values for different originals with same month/day', () {
      expect(
        DateTime(2024, 3, 15).toAnnualDate,
        DateTime(1999, 3, 15).toAnnualDate,
      );
    });

    test('should produce a local (non-UTC) date even for a UTC receiver', () {
      final DateTime annual = DateTime.utc(2024, 3, 15, 10).toAnnualDate;
      expect(annual.isUtc, isFalse);
      expect(annual, DateTime(0, 3, 15));
    });

    test('should round-trip in range via isAnnualDateInRange (same-year range)', () {
      final DateTime annual = DateTime(2024, 6, 15).toAnnualDate;
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2030, 6, 1),
        end: DateTime(2030, 6, 30),
      );
      expect(annual.isAnnualDateInRange(range), isTrue);
    });

    test('should round-trip out of range via isAnnualDateInRange', () {
      final DateTime annual = DateTime(2024, 8, 15).toAnnualDate;
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2030, 6, 1),
        end: DateTime(2030, 6, 30),
      );
      expect(annual.isAnnualDateInRange(range), isFalse);
    });

    test('should match a year-boundary-spanning range when month/day falls inside', () {
      // Dec 20 -> Jan 10 spans two calendar years; the documented motivation
      // for year 0 is that the consumer probes every year in the range.
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2023, 12, 20),
        end: DateTime(2024, 1, 10),
      );
      expect(DateTime(1990, 12, 25).toAnnualDate.isAnnualDateInRange(range), isTrue);
      expect(DateTime(1990, 1, 5).toAnnualDate.isAnnualDateInRange(range), isTrue);
      expect(DateTime(1990, 6, 15).toAnnualDate.isAnnualDateInRange(range), isFalse);
    });

    test('should build valid annual dates for extreme years', () {
      expect(DateTime(1, 1, 1).toAnnualDate, DateTime(0, 1, 1));
      expect(DateTime(9999, 12, 31).toAnnualDate, DateTime(0, 12, 31));
    });
  });

  group('toDayRange', () {
    test('should cover full day with microsecond-precision end', () {
      final DateTime date = DateTime(2024, 3, 15, 10, 30);
      final DateTimeRange range = date.toDayRange();
      expect(range.start, DateTime(2024, 3, 15, 0, 0, 0, 0));
      // Composes endOfDay -> microsecond precision, not millisecond-truncated.
      expect(range.end, DateTime(2024, 3, 15, 23, 59, 59, 999, 999));
    });

    test('should pin the end microsecond to lock the precision contract', () {
      final DateTimeRange range = DateTime(2024, 3, 15, 10, 30).toDayRange();
      expect(range.end.microsecond, 999);
      expect(range.end.millisecond, 999);
    });

    test('should start at midnight on the same calendar day', () {
      final DateTimeRange range = DateTime(2024, 3, 15, 10, 30).toDayRange();
      expect(range.start.day, range.end.day);
      expect(range.start.hour, 0);
      expect(range.start.minute, 0);
      expect(range.start.second, 0);
      expect(range.start.millisecond, 0);
      expect(range.start.microsecond, 0);
    });

    test('should be ordered and non-empty', () {
      final DateTimeRange range = DateTime(2024, 3, 15).toDayRange();
      expect(range.start.isBefore(range.end), isTrue);
    });

    test('should span one tick short of 24h on a non-DST day', () {
      // June 15 carries no DST transition in any common zone, so the wall-clock
      // span equals real elapsed time: 23:59:59.999999.
      final DateTimeRange range = DateTime(2024, 6, 15).toDayRange();
      expect(
        range.duration,
        const Duration(
          hours: 23,
          minutes: 59,
          seconds: 59,
          milliseconds: 999,
          microseconds: 999,
        ),
      );
    });

    test('should use wall-clock construction independent of real elapsed time (DST)', () {
      // The DST contract: toDayRange builds bounds from wall-clock components
      // via startOfDay/endOfDay, so the wall-clock end is always
      // 23:59:59.999999 regardless of whether the local day had a skipped or
      // repeated hour. Real-time duration on a transition day therefore differs
      // from 24h, but the wall-clock components are fixed. Asserting the
      // wall-clock components (not a host-TZ-dependent real duration) keeps this
      // deterministic on any CI host. US spring-forward 2024 fell on Mar 10.
      final DateTimeRange spring = DateTime(2024, 3, 10).toDayRange();
      expect(spring.start.hour, 0);
      expect(spring.end.hour, 23);
      expect(spring.end.minute, 59);
      expect(spring.end.second, 59);

      // US fall-back 2024 fell on Nov 3 (a 25-hour real day in DST zones).
      final DateTimeRange fall = DateTime(2024, 11, 3).toDayRange();
      expect(fall.start.hour, 0);
      expect(fall.end.hour, 23);
      expect(fall.end.minute, 59);
      expect(fall.end.second, 59);
    });

    test('should keep both bounds on Feb 29 for a leap-day input', () {
      final DateTimeRange range = DateTime(2024, 2, 29).toDayRange();
      expect(range.start, DateTime(2024, 2, 29));
      expect(range.end.month, 2);
      expect(range.end.day, 29);
    });

    test('should not bleed into the next day for a Dec 31 input', () {
      final DateTimeRange range = DateTime(2024, 12, 31, 8).toDayRange();
      expect(range.start, DateTime(2024, 12, 31));
      expect(range.end.year, 2024);
      expect(range.end.month, 12);
      expect(range.end.day, 31);
    });

    test('should not bleed into the previous day for a Jan 1 input', () {
      final DateTimeRange range = DateTime(2024, 1, 1, 8).toDayRange();
      expect(range.start, DateTime(2024, 1, 1));
      expect(range.end.day, 1);
      expect(range.end.month, 1);
    });

    test('should produce local bounds even for a UTC receiver', () {
      final DateTimeRange range = DateTime.utc(2024, 3, 15, 10).toDayRange();
      // startOfDay/endOfDay build local DateTimes, so the UTC flag is dropped.
      expect(range.start.isUtc, isFalse);
      expect(range.end.isUtc, isFalse);
    });

    test('should build valid ranges for extreme years without overflow', () {
      final DateTimeRange early = DateTime(1, 6, 15).toDayRange();
      expect(early.start, DateTime(1, 6, 15));
      expect(early.end, DateTime(1, 6, 15, 23, 59, 59, 999, 999));

      final DateTimeRange late = DateTime(9999, 6, 15).toDayRange();
      expect(late.start, DateTime(9999, 6, 15));
      expect(late.end, DateTime(9999, 6, 15, 23, 59, 59, 999, 999));
    });
  });
}
