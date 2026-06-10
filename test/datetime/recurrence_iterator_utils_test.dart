import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/recurrence_iterator_utils.dart';
import 'package:saropa_dart_utils/datetime/rrule_parse_utils.dart';

void main() {
  group('expandRecurrence', () {
    test('should expand a daily rule with COUNT', () {
      final RecurrenceRule rule = parseRrule('FREQ=DAILY;COUNT=3');

      final List<DateTime> dates = expandRecurrence(rule, DateTime(2026, 1, 1)).toList();

      expect(dates, equals(<DateTime>[DateTime(2026, 1, 1), DateTime(2026, 1, 2), DateTime(2026, 1, 3)]));
    });

    test('should honor INTERVAL on a daily rule', () {
      final RecurrenceRule rule = parseRrule('FREQ=DAILY;INTERVAL=2;COUNT=3');

      final List<DateTime> dates = expandRecurrence(rule, DateTime(2026, 1, 1)).toList();

      expect(dates, equals(<DateTime>[DateTime(2026, 1, 1), DateTime(2026, 1, 3), DateTime(2026, 1, 5)]));
    });

    test('should expand a weekly BYDAY rule in date order', () {
      // 2026-01-05 is a Monday.
      final RecurrenceRule rule = parseRrule('FREQ=WEEKLY;BYDAY=MO,WE;COUNT=4');

      final List<DateTime> dates = expandRecurrence(rule, DateTime(2026, 1, 5)).toList();

      expect(
        dates,
        equals(<DateTime>[
          DateTime(2026, 1, 5),
          DateTime(2026, 1, 7),
          DateTime(2026, 1, 12),
          DateTime(2026, 1, 14),
        ]),
      );
    });

    test('should skip the unpaired tail before start in the first week', () {
      // Start on Wednesday; the Monday of that week is before start and dropped.
      final RecurrenceRule rule = parseRrule('FREQ=WEEKLY;BYDAY=MO,WE;COUNT=3');

      final List<DateTime> dates = expandRecurrence(rule, DateTime(2026, 1, 7)).toList();

      expect(dates.first, equals(DateTime(2026, 1, 7)));
      expect(dates, equals(<DateTime>[DateTime(2026, 1, 7), DateTime(2026, 1, 12), DateTime(2026, 1, 14)]));
    });

    test('should honor a weekly INTERVAL of 2', () {
      final RecurrenceRule rule = parseRrule('FREQ=WEEKLY;INTERVAL=2;COUNT=3');

      final List<DateTime> dates = expandRecurrence(rule, DateTime(2026, 1, 5)).toList();

      expect(dates, equals(<DateTime>[DateTime(2026, 1, 5), DateTime(2026, 1, 19), DateTime(2026, 2, 2)]));
    });

    test('should expand monthly on a fixed BYMONTHDAY', () {
      final RecurrenceRule rule = parseRrule('FREQ=MONTHLY;BYMONTHDAY=15;COUNT=3');

      final List<DateTime> dates = expandRecurrence(rule, DateTime(2026, 1, 1)).toList();

      expect(dates, equals(<DateTime>[DateTime(2026, 1, 15), DateTime(2026, 2, 15), DateTime(2026, 3, 15)]));
    });

    test('should skip months without a day-31 when BYMONTHDAY=31', () {
      final RecurrenceRule rule = parseRrule('FREQ=MONTHLY;BYMONTHDAY=31;COUNT=4');

      final List<DateTime> dates = expandRecurrence(rule, DateTime(2026)).toList();

      // Jan, Mar, May, Jul have 31; Feb, Apr, Jun are skipped.
      expect(
        dates,
        equals(<DateTime>[
          DateTime(2026, 1, 31),
          DateTime(2026, 3, 31),
          DateTime(2026, 5, 31),
          DateTime(2026, 7, 31),
        ]),
      );
    });

    test('should resolve a negative BYMONTHDAY to the month end', () {
      final RecurrenceRule rule = parseRrule('FREQ=MONTHLY;BYMONTHDAY=-1;COUNT=3');

      final List<DateTime> dates = expandRecurrence(rule, DateTime(2026, 1, 1)).toList();

      // Last day of Jan (31), Feb (28, 2026 non-leap), Mar (31).
      expect(dates, equals(<DateTime>[DateTime(2026, 1, 31), DateTime(2026, 2, 28), DateTime(2026, 3, 31)]));
    });

    test('should default monthly to the start day-of-month', () {
      final RecurrenceRule rule = parseRrule('FREQ=MONTHLY;COUNT=2');

      final List<DateTime> dates = expandRecurrence(rule, DateTime(2026, 1, 20)).toList();

      expect(dates, equals(<DateTime>[DateTime(2026, 1, 20), DateTime(2026, 2, 20)]));
    });

    test('should expand yearly on BYMONTH', () {
      final RecurrenceRule rule = parseRrule('FREQ=YEARLY;BYMONTH=3,6;COUNT=4');

      final List<DateTime> dates = expandRecurrence(rule, DateTime(2026, 1, 10)).toList();

      expect(
        dates,
        equals(<DateTime>[
          DateTime(2026, 3, 10),
          DateTime(2026, 6, 10),
          DateTime(2027, 3, 10),
          DateTime(2027, 6, 10),
        ]),
      );
    });

    test('should stop at UNTIL inclusive', () {
      final RecurrenceRule rule = parseRrule('FREQ=DAILY;UNTIL=20260103');

      final List<DateTime> dates = expandRecurrence(rule, DateTime(2026, 1, 1)).toList();

      expect(dates, equals(<DateTime>[DateTime(2026, 1, 1), DateTime(2026, 1, 2), DateTime(2026, 1, 3)]));
    });

    test('should cap with the limit argument on an unbounded rule', () {
      final RecurrenceRule rule = parseRrule('FREQ=DAILY');

      final List<DateTime> dates = expandRecurrence(rule, DateTime(2026, 1, 1), limit: 5).toList();

      expect(dates.length, equals(5));
    });

    test('should be lazy: take(n) bounds an infinite rule', () {
      final RecurrenceRule rule = parseRrule('FREQ=YEARLY');

      final List<DateTime> dates = expandRecurrence(rule, DateTime(2000, 2, 29)).take(2).toList();

      // 2000 is a leap year; the next Feb-29 leap year is 2004.
      expect(dates, equals(<DateTime>[DateTime(2000, 2, 29), DateTime(2004, 2, 29)]));
    });

    test('should preserve time-of-day and UTC-ness', () {
      final RecurrenceRule rule = parseRrule('FREQ=DAILY;COUNT=2');

      final List<DateTime> dates = expandRecurrence(rule, DateTime.utc(2026, 1, 1, 9, 30)).toList();

      expect(dates, equals(<DateTime>[DateTime.utc(2026, 1, 1, 9, 30), DateTime.utc(2026, 1, 2, 9, 30)]));
      expect(dates.first.isUtc, isTrue);
    });
  });
}
