import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/business_calendar_utils.dart';
import 'package:saropa_dart_utils/datetime/sla_calculator_utils.dart';

void main() {
  group('OpenWindow', () {
    test('should reject an inverted window', () {
      expect(() => OpenWindow(600, 600), throwsA(isA<AssertionError>()));
      expect(() => OpenWindow(-1, 60), throwsA(isA<AssertionError>()));
    });
  });

  group('BusinessHours.uniform', () {
    test('should apply the window to weekdays only by default', () {
      final BusinessHours hours = BusinessHours.uniform(openMinute: 540, closeMinute: 1020);

      expect(hours.windowsFor(DateTime.monday), hasLength(1));
      expect(hours.windowsFor(DateTime.saturday), isEmpty);
    });
  });

  group('SlaCalculator', () {
    // 9:00–17:00 (540–1020), Monday–Friday.
    final BusinessHours nineToFive = BusinessHours.uniform(openMinute: 540, closeMinute: 1020);
    final SlaCalculator sla = SlaCalculator(nineToFive);

    group('isOpen', () {
      test('should be true inside a window on a weekday', () {
        // 2026-06-01 is a Monday.
        expect(sla.isOpen(DateTime(2026, 6, 1, 10)), isTrue);
      });

      test('should be false before open, at close, and on weekends', () {
        expect(sla.isOpen(DateTime(2026, 6, 1, 8, 59)), isFalse);
        expect(sla.isOpen(DateTime(2026, 6, 1, 17)), isFalse); // close is exclusive
        expect(sla.isOpen(DateTime(2026, 6, 6, 10)), isFalse); // Saturday
      });
    });

    group('addWorkingTime', () {
      test('should stay within the same day when it fits', () {
        // Mon 10:00 + 4h = Mon 14:00.
        expect(
          sla.addWorkingTime(DateTime(2026, 6, 1, 10), const Duration(hours: 4)),
          equals(DateTime(2026, 6, 1, 14)),
        );
      });

      test('should roll to the next working day across a close boundary', () {
        // Mon 15:00 + 4h: 2h Mon (to 17:00) + 2h Tue (from 09:00) = Tue 11:00.
        expect(
          sla.addWorkingTime(DateTime(2026, 6, 1, 15), const Duration(hours: 4)),
          equals(DateTime(2026, 6, 2, 11)),
        );
      });

      test('should skip the weekend', () {
        // Fri 16:00 + 2h: 1h Fri (to 17:00) + 1h Mon (from 09:00) = Mon 10:00.
        expect(
          sla.addWorkingTime(DateTime(2026, 6, 5, 16), const Duration(hours: 2)),
          equals(DateTime(2026, 6, 8, 10)),
        );
      });

      test('should clamp a start before open to the open time', () {
        // Mon 07:00 + 1h counts from 09:00 = Mon 10:00.
        expect(
          sla.addWorkingTime(DateTime(2026, 6, 1, 7), const Duration(hours: 1)),
          equals(DateTime(2026, 6, 1, 10)),
        );
      });

      test('should skip a holiday via the calendar', () {
        final SlaCalculator withHoliday = SlaCalculator(
          nineToFive,
          calendar: BusinessCalendar(holidays: <DateTime>[DateTime(2026, 6, 2)]), // Tue
        );

        // Mon 16:00 + 2h: 1h Mon, Tue is a holiday, 1h Wed = Wed 10:00.
        expect(
          withHoliday.addWorkingTime(DateTime(2026, 6, 1, 16), const Duration(hours: 2)),
          equals(DateTime(2026, 6, 3, 10)),
        );
      });

      test('should return start unchanged for a non-positive amount', () {
        final DateTime start = DateTime(2026, 6, 1, 10);
        expect(sla.addWorkingTime(start, Duration.zero), equals(start));
      });

      test('should throw when no working time exists', () {
        final SlaCalculator closed = SlaCalculator(BusinessHours(<int, List<OpenWindow>>{}));
        expect(
          () => closed.addWorkingTime(DateTime(2026, 6, 1, 10), const Duration(hours: 1)),
          throwsStateError,
        );
      });
    });

    group('workingTimeBetween', () {
      test('should count only open hours across days', () {
        // Mon 16:00 → Tue 10:00: 1h Mon + 1h Tue = 2h.
        expect(
          sla.workingTimeBetween(DateTime(2026, 6, 1, 16), DateTime(2026, 6, 2, 10)),
          equals(const Duration(hours: 2)),
        );
      });

      test('should exclude weekend time', () {
        // Fri 16:00 → Mon 10:00: 1h Fri + 1h Mon = 2h (weekend excluded).
        expect(
          sla.workingTimeBetween(DateTime(2026, 6, 5, 16), DateTime(2026, 6, 8, 10)),
          equals(const Duration(hours: 2)),
        );
      });

      test('should return zero when end is not after start', () {
        expect(
          sla.workingTimeBetween(DateTime(2026, 6, 2), DateTime(2026, 6, 1)),
          equals(Duration.zero),
        );
      });

      test('should round-trip with addWorkingTime', () {
        final DateTime start = DateTime(2026, 6, 1, 11);
        final DateTime due = sla.addWorkingTime(start, const Duration(hours: 10));

        expect(sla.workingTimeBetween(start, due), equals(const Duration(hours: 10)));
      });
    });

    test('should keep UTC inputs in UTC', () {
      // Mon 15:00 UTC + 4h = 2h Mon + 2h Tue (from 09:00) = Tue 11:00 UTC.
      final DateTime due = sla.addWorkingTime(DateTime.utc(2026, 6, 1, 15), const Duration(hours: 4));

      expect(due, equals(DateTime.utc(2026, 6, 2, 11)));
      expect(due.isUtc, isTrue);
    });
  });
}
