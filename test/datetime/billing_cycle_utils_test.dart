import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/billing_cycle_utils.dart';

void main() {
  group('billingDateInMonth', () {
    test('should return the anchor day for a normal month', () {
      expect(billingDateInMonth(2026, 1, 15), equals(DateTime(2026, 1, 15)));
    });

    test('should clamp anchor 31 to February in a non-leap year', () {
      expect(billingDateInMonth(2026, 2, 31), equals(DateTime(2026, 2, 28)));
    });

    test('should clamp anchor 31 to February 29 in a leap year', () {
      expect(billingDateInMonth(2024, 2, 31), equals(DateTime(2024, 2, 29)));
    });

    test('should clamp anchor 31 to a 30-day month', () {
      expect(billingDateInMonth(2026, 4, 31), equals(DateTime(2026, 4, 30)));
    });

    test('should reject an out-of-range anchor day', () {
      expect(() => billingDateInMonth(2026, 1, 0), throwsArgumentError);
      expect(() => billingDateInMonth(2026, 1, 32), throwsArgumentError);
    });
  });

  group('nextBillingDate', () {
    test('should return this month when from is before the anchor', () {
      expect(nextBillingDate(DateTime(2026, 3, 10), 15), equals(DateTime(2026, 3, 15)));
    });

    test('should return the same date when from is exactly on the anchor', () {
      expect(nextBillingDate(DateTime(2026, 3, 15), 15), equals(DateTime(2026, 3, 15)));
    });

    test('should roll to next month when from is past the anchor', () {
      expect(nextBillingDate(DateTime(2026, 3, 20), 15), equals(DateTime(2026, 4, 15)));
    });

    test('should ignore the time component of from', () {
      expect(
        nextBillingDate(DateTime(2026, 3, 15, 23, 59), 15),
        equals(DateTime(2026, 3, 15)),
      );
    });

    test('should clamp when rolling into a short month', () {
      // From Jan 31 past the anchor lands on the clamped Feb date.
      expect(nextBillingDate(DateTime(2026, 2, 1), 31), equals(DateTime(2026, 2, 28)));
    });
  });

  group('billingSchedule', () {
    test('should produce consecutive monthly dates across a year', () {
      final List<DateTime> dates = billingSchedule(DateTime(2026, 1, 15), 15, 12);

      expect(dates.length, equals(12));
      expect(dates.first, equals(DateTime(2026, 1, 15)));
      expect(dates.last, equals(DateTime(2026, 12, 15)));
    });

    test('should clamp February when stepping anchor 31 across the year', () {
      final List<DateTime> dates = billingSchedule(DateTime(2026, 1, 31), 31, 4);

      expect(
        dates,
        equals(<DateTime>[
          DateTime(2026, 1, 31),
          DateTime(2026, 2, 28),
          DateTime(2026, 3, 31),
          DateTime(2026, 4, 30),
        ]),
      );
    });

    test('should return empty for a zero count', () {
      expect(billingSchedule(DateTime(2026, 1, 15), 15, 0), isEmpty);
    });

    test('should reject a negative count', () {
      expect(() => billingSchedule(DateTime(2026, 1, 15), 15, -1), throwsArgumentError);
    });
  });

  group('currentCycle', () {
    test('should bound the cycle containing the date, end exclusive', () {
      final ({DateTime start, DateTime end}) cycle = currentCycle(DateTime(2026, 3, 20), 15);

      expect(cycle.start, equals(DateTime(2026, 3, 15)));
      expect(cycle.end, equals(DateTime(2026, 4, 15)));
    });

    test('should start the cycle on the anchor day itself', () {
      final ({DateTime start, DateTime end}) cycle = currentCycle(DateTime(2026, 3, 15), 15);

      expect(cycle.start, equals(DateTime(2026, 3, 15)));
      expect(cycle.end, equals(DateTime(2026, 4, 15)));
    });

    test('should use the previous month when before this month anchor', () {
      final ({DateTime start, DateTime end}) cycle = currentCycle(DateTime(2026, 3, 10), 15);

      expect(cycle.start, equals(DateTime(2026, 2, 15)));
      expect(cycle.end, equals(DateTime(2026, 3, 15)));
    });

    test('should clamp the cycle end into a short month', () {
      // Cycle opening Jan 31 ends on the clamped Feb 28/29 date.
      final ({DateTime start, DateTime end}) cycle = currentCycle(DateTime(2024, 1, 31), 31);

      expect(cycle.start, equals(DateTime(2024, 1, 31)));
      expect(cycle.end, equals(DateTime(2024, 2, 29)));
    });
  });
}
