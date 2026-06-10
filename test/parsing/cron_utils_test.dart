import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/cron_utils.dart';

void main() {
  group('CronSchedule.tryParse', () {
    test('rejects the wrong number of fields', () {
      expect(CronSchedule.tryParse('* * * *'), isNull);
      expect(CronSchedule.tryParse('* * * * * *'), isNull);
      expect(CronSchedule.tryParse('bad'), isNull);
    });

    test('rejects out-of-range values', () {
      expect(CronSchedule.tryParse('60 * * * *'), isNull); // minute max 59
      expect(CronSchedule.tryParse('0 0 32 1 *'), isNull); // day-of-month max 31
      expect(CronSchedule.tryParse('0 0 1 13 *'), isNull); // month max 12
    });

    test('parses lists, ranges, and steps', () {
      final CronSchedule s = CronSchedule.tryParse('0,30 9-17 * * 1-5')!;
      expect(s.minutes, <int>{0, 30});
      expect(s.hours, <int>{9, 10, 11, 12, 13, 14, 15, 16, 17});
      expect(s.daysOfWeek, <int>{1, 2, 3, 4, 5});
    });

    test('expands a step field', () {
      expect(CronSchedule.tryParse(r'*/15 * * * *')!.minutes, <int>{0, 15, 30, 45});
    });

    test('normalizes Sunday-as-7 to 0', () {
      expect(CronSchedule.tryParse('0 0 * * 7')!.daysOfWeek, <int>{0});
    });
  });

  group('nextRunAfter', () {
    test('every 15 minutes finds the next quarter-hour', () {
      final CronSchedule s = CronSchedule.tryParse(r'*/15 * * * *')!;
      expect(
        s.nextRunAfter(DateTime(2026, 1, 1, 0, 7)),
        DateTime(2026, 1, 1, 0, 15),
      );
    });

    test('daily 09:00 rolls to the next day when already past', () {
      final CronSchedule s = CronSchedule.tryParse('0 9 * * *')!;
      expect(
        s.nextRunAfter(DateTime(2026, 1, 1, 10, 0)),
        DateTime(2026, 1, 2, 9, 0),
      );
    });

    test('strictly after: an exact match advances to the following run', () {
      final CronSchedule s = CronSchedule.tryParse('0 9 * * *')!;
      // Already at 09:00 -> next is tomorrow, not now.
      expect(
        s.nextRunAfter(DateTime(2026, 1, 1, 9, 0)),
        DateTime(2026, 1, 2, 9, 0),
      );
    });

    test('day-of-week selects the next matching weekday', () {
      // 2026-01-01 is a Thursday; next Monday is 2026-01-05.
      final CronSchedule s = CronSchedule.tryParse('0 0 * * 1')!;
      expect(
        s.nextRunAfter(DateTime(2026, 1, 1, 12, 0)),
        DateTime(2026, 1, 5, 0, 0),
      );
    });

    test('finds a leap-day schedule across years', () {
      final CronSchedule s = CronSchedule.tryParse('0 0 29 2 *')!;
      expect(
        s.nextRunAfter(DateTime(2026, 3, 1)),
        DateTime(2028, 2, 29, 0, 0),
      );
    });

    test('returns null for an impossible schedule', () {
      // February never has 31 days.
      final CronSchedule s = CronSchedule.tryParse('0 0 31 2 *')!;
      expect(s.nextRunAfter(DateTime(2026, 1, 1)), isNull);
    });
  });
}
