import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/rrule_parse_utils.dart';

void main() {
  group('parseRrule', () {
    test('should parse a weekly rule with interval, byday, and count', () {
      final RecurrenceRule rule = parseRrule('FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR;COUNT=10');

      expect(rule.frequency, equals(RecurFrequency.weekly));
      expect(rule.interval, equals(2));
      expect(rule.count, equals(10));
      expect(
        rule.byWeekDays,
        equals(<RecurWeekday>[RecurWeekday.monday, RecurWeekday.wednesday, RecurWeekday.friday]),
      );
    });

    test('should default interval to 1 and weekStart to Monday', () {
      final RecurrenceRule rule = parseRrule('FREQ=DAILY');

      expect(rule.interval, equals(1));
      expect(rule.weekStart, equals(RecurWeekday.monday));
      expect(rule.count, isNull);
      expect(rule.until, isNull);
      expect(rule.byWeekDays, isEmpty);
    });

    test('should accept a leading RRULE: prefix', () {
      final RecurrenceRule rule = parseRrule('RRULE:FREQ=MONTHLY;BYMONTHDAY=15');

      expect(rule.frequency, equals(RecurFrequency.monthly));
      expect(rule.byMonthDays, equals(<int>[15]));
    });

    test('should be order-independent and let the last duplicate win', () {
      final RecurrenceRule rule = parseRrule('INTERVAL=3;FREQ=YEARLY;INTERVAL=5');

      expect(rule.frequency, equals(RecurFrequency.yearly));
      expect(rule.interval, equals(5));
    });

    test('should parse a date-only UTC UNTIL', () {
      final RecurrenceRule rule = parseRrule('FREQ=DAILY;UNTIL=20261231Z');

      expect(rule.until, equals(DateTime.utc(2026, 12, 31)));
    });

    test('should parse a date-time UTC UNTIL', () {
      final RecurrenceRule rule = parseRrule('FREQ=DAILY;UNTIL=20261231T235959Z');

      expect(rule.until, equals(DateTime.utc(2026, 12, 31, 23, 59, 59)));
    });

    test('should parse a floating (non-Z) UNTIL as local', () {
      final RecurrenceRule rule = parseRrule('FREQ=DAILY;UNTIL=20260101T090000');

      expect(rule.until, equals(DateTime(2026, 1, 1, 9)));
      expect(rule.until!.isUtc, isFalse);
    });

    test('should parse negative BYMONTHDAY (from month end)', () {
      final RecurrenceRule rule = parseRrule('FREQ=MONTHLY;BYMONTHDAY=-1');

      expect(rule.byMonthDays, equals(<int>[-1]));
    });

    test('should parse BYMONTH and WKST', () {
      final RecurrenceRule rule = parseRrule('FREQ=YEARLY;BYMONTH=1,6,12;WKST=SU');

      expect(rule.byMonths, equals(<int>[1, 6, 12]));
      expect(rule.weekStart, equals(RecurWeekday.sunday));
    });

    test('should support value equality', () {
      final RecurrenceRule a = parseRrule('FREQ=WEEKLY;BYDAY=MO,FR');
      final RecurrenceRule b = parseRrule('FREQ=WEEKLY;BYDAY=MO,FR');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    group('errors', () {
      test('should throw when FREQ is missing', () {
        expect(() => parseRrule('INTERVAL=2'), throwsFormatException);
      });

      test('should throw on an unknown FREQ', () {
        expect(() => parseRrule('FREQ=HOURLY'), throwsFormatException);
      });

      test('should throw on an unsupported part', () {
        expect(() => parseRrule('FREQ=DAILY;BYSETPOS=1'), throwsFormatException);
      });

      test('should throw on a non-positive interval', () {
        expect(() => parseRrule('FREQ=DAILY;INTERVAL=0'), throwsFormatException);
      });

      test('should throw on an invalid weekday code', () {
        expect(() => parseRrule('FREQ=WEEKLY;BYDAY=XX'), throwsFormatException);
      });

      test('should throw on BYMONTH out of range', () {
        expect(() => parseRrule('FREQ=YEARLY;BYMONTH=13'), throwsFormatException);
      });

      test('should throw on BYMONTHDAY of 0', () {
        expect(() => parseRrule('FREQ=MONTHLY;BYMONTHDAY=0'), throwsFormatException);
      });

      test('should throw on a malformed UNTIL', () {
        expect(() => parseRrule('FREQ=DAILY;UNTIL=2026-12-31'), throwsFormatException);
      });

      test('should throw on a part without =', () {
        expect(() => parseRrule('FREQ=DAILY;NONSENSE'), throwsFormatException);
      });
    });
  });
}
