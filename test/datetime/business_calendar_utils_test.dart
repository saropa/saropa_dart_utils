import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/business_calendar_utils.dart';

void main() {
  group('BusinessCalendar', () {
    // 2026-01-01 (Thu) is a holiday; 2026-01-03/04 is the weekend (Sat/Sun).
    final BusinessCalendar calendar = BusinessCalendar(
      holidays: <DateTime>[DateTime(2026), DateTime(2026, 1, 2)],
    );

    group('isBusinessDay', () {
      test('should be false on a weekend', () {
        expect(calendar.isBusinessDay(DateTime(2026, 1, 3)), isFalse); // Saturday
        expect(calendar.isWeekend(DateTime(2026, 1, 3)), isTrue);
      });

      test('should be false on a holiday', () {
        expect(calendar.isBusinessDay(DateTime(2026)), isFalse);
        expect(calendar.isHoliday(DateTime(2026)), isTrue);
      });

      test('should be true on a plain weekday', () {
        expect(calendar.isBusinessDay(DateTime(2026, 1, 5)), isTrue); // Monday
      });

      test('should ignore the time-of-day when matching a holiday', () {
        expect(calendar.isHoliday(DateTime(2026, 1, 1, 14, 30)), isTrue);
      });
    });

    group('nextBusinessDay / previousBusinessDay', () {
      test('should skip the New Year holidays and the weekend', () {
        // From Wed 2025-12-31, the next working day is Mon 2026-01-05
        // (Thu 1 + Fri 2 are holidays, Sat 3 + Sun 4 the weekend).
        expect(calendar.nextBusinessDay(DateTime(2025, 12, 31)), equals(DateTime(2026, 1, 5)));
      });

      test('should step strictly forward even from a business day', () {
        expect(calendar.nextBusinessDay(DateTime(2026, 1, 5)), equals(DateTime(2026, 1, 6)));
      });

      test('should step backward over weekend and holidays', () {
        expect(calendar.previousBusinessDay(DateTime(2026, 1, 5)), equals(DateTime(2025, 12, 31)));
      });
    });

    group('addBusinessDays', () {
      test('should add forward over holidays and weekend', () {
        // Wed 2025-12-31 + 1 business day = Mon 2026-01-05.
        expect(calendar.addBusinessDays(DateTime(2025, 12, 31), 1), equals(DateTime(2026, 1, 5)));
      });

      test('should subtract backward', () {
        expect(calendar.addBusinessDays(DateTime(2026, 1, 5), -1), equals(DateTime(2025, 12, 31)));
      });

      test('should return the input unchanged for n == 0', () {
        final DateTime input = DateTime(2026, 1, 5, 8, 15);
        expect(calendar.addBusinessDays(input, 0), equals(input));
      });
    });

    group('businessDaysBetween', () {
      test('should exclude weekends and holidays in a span', () {
        // 2026-01-01..2026-01-08 exclusive: holidays Thu 1 + Fri 2, weekend Sat
        // 3 + Sun 4; working days are Mon 5, Tue 6, Wed 7 = 3.
        expect(calendar.businessDaysBetween(DateTime(2026), DateTime(2026, 1, 8)), equals(3));
      });

      test('should return 0 when end is not after start', () {
        expect(calendar.businessDaysBetween(DateTime(2026, 1, 8), DateTime(2026)), equals(0));
      });
    });

    group('businessDaysIn', () {
      test('should list the working days in a span', () {
        final List<DateTime> days = calendar.businessDaysIn(DateTime(2026), DateTime(2026, 1, 8));

        expect(days, equals(<DateTime>[DateTime(2026, 1, 5), DateTime(2026, 1, 6), DateTime(2026, 1, 7)]));
      });
    });

    group('custom weekend', () {
      test('should honor a Friday/Saturday weekend', () {
        final BusinessCalendar friSat = BusinessCalendar(
          weekendDays: <int>{DateTime.friday, DateTime.saturday},
        );

        expect(friSat.isWeekend(DateTime(2026, 1, 2)), isTrue); // Friday
        expect(friSat.isWeekend(DateTime(2026, 1, 4)), isFalse); // Sunday is a workday
        expect(friSat.isBusinessDay(DateTime(2026, 1, 4)), isTrue);
      });
    });
  });
}
