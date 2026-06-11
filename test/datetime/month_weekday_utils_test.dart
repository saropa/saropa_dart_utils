import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/month_weekday_utils.dart';

void main() {
  group('MonthWeekdayUtils.nthWeekdayOfMonth', () {
    test('returns the 2nd Sunday of March 2026 (US DST start)', () {
      expect(
        MonthWeekdayUtils.nthWeekdayOfMonth(2026, 3, 2, DateTime.sunday),
        DateTime(2026, 3, 8),
      );
    });

    test('returns the 1st Monday of June 2026', () {
      expect(
        MonthWeekdayUtils.nthWeekdayOfMonth(2026, 6, 1, DateTime.monday),
        DateTime(2026, 6),
      );
    });

    test('returns the 5th Friday of January 2026 (exists)', () {
      expect(
        MonthWeekdayUtils.nthWeekdayOfMonth(2026, 1, 5, DateTime.friday),
        DateTime(2026, 1, 30),
      );
    });

    test('returns null for a 5th Friday of February 2026 (does not exist)', () {
      expect(
        MonthWeekdayUtils.nthWeekdayOfMonth(2026, 2, 5, DateTime.friday),
        isNull,
      );
    });

    test('returns null for n < 1', () {
      expect(MonthWeekdayUtils.nthWeekdayOfMonth(2026, 3, 0, DateTime.sunday), isNull);
    });

    test('returns null for an out-of-range month', () {
      expect(MonthWeekdayUtils.nthWeekdayOfMonth(2026, 13, 1, DateTime.sunday), isNull);
      expect(MonthWeekdayUtils.nthWeekdayOfMonth(2026, 0, 1, DateTime.sunday), isNull);
    });

    test('returns null for an out-of-range weekday', () {
      expect(MonthWeekdayUtils.nthWeekdayOfMonth(2026, 3, 1, 8), isNull);
      expect(MonthWeekdayUtils.nthWeekdayOfMonth(2026, 3, 1, 0), isNull);
    });
  });

  group('MonthWeekdayUtils.lastWeekdayOfMonth', () {
    test('returns the last Sunday of October 2026 (EU DST end)', () {
      expect(
        MonthWeekdayUtils.lastWeekdayOfMonth(2026, 10, DateTime.sunday),
        DateTime(2026, 10, 25),
      );
    });

    test('returns the last Sunday of March 2026 (EU DST start)', () {
      expect(
        MonthWeekdayUtils.lastWeekdayOfMonth(2026, 3, DateTime.sunday),
        DateTime(2026, 3, 29),
      );
    });

    test('handles a 28-day February (last Monday Feb 2026)', () {
      expect(
        MonthWeekdayUtils.lastWeekdayOfMonth(2026, 2, DateTime.monday),
        DateTime(2026, 2, 23),
      );
    });

    test('handles a leap-year February (last Friday Feb 2024)', () {
      expect(
        MonthWeekdayUtils.lastWeekdayOfMonth(2024, 2, DateTime.friday),
        DateTime(2024, 2, 23),
      );
    });

    test('handles December (next-month rollover) (last Thursday Dec 2026)', () {
      expect(
        MonthWeekdayUtils.lastWeekdayOfMonth(2026, 12, DateTime.thursday),
        DateTime(2026, 12, 31),
      );
    });
  });
}
