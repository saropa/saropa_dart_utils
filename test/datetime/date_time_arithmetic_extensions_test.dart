// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/date_time_arithmetic_extensions.dart';

void main() {
  group('DateTimeArithmeticExtensions', () {
    group('getTimeDifferenceMs', () {
      test('returns null when compareTo is null', () {
        expect(DateTime(2023).getTimeDifferenceMs(null), isNull);
      });

      test('returns absolute difference by default (later - earlier)', () {
        final DateTime a = DateTime(2023, 1, 1, 0, 0, 0);
        final DateTime b = DateTime(2023, 1, 1, 0, 0, 1);
        expect(a.getTimeDifferenceMs(b), 1000);
      });

      test('returns absolute difference by default (earlier - later)', () {
        final DateTime a = DateTime(2023, 1, 1, 0, 0, 1);
        final DateTime b = DateTime(2023, 1, 1, 0, 0, 0);
        expect(a.getTimeDifferenceMs(b), 1000);
      });

      test('returns signed difference when isAlwaysPositive is false', () {
        final DateTime a = DateTime(2023, 1, 1, 0, 0, 0);
        final DateTime b = DateTime(2023, 1, 1, 0, 0, 1);
        expect(a.getTimeDifferenceMs(b, isAlwaysPositive: false), -1000);
      });

      test('returns 0 for identical instants', () {
        final DateTime a = DateTime(2023, 6, 15, 10, 30);
        expect(a.getTimeDifferenceMs(a), 0);
      });
    });

    group('addYears', () {
      test('returns same instance for 0 years', () {
        final DateTime d = DateTime(2023, 6, 15);
        expect(d.addYears(0), same(d));
      });

      test('adds one year', () {
        expect(DateTime(2023, 6, 15).addYears(1), DateTime(2024, 6, 15));
      });

      test('Feb 29 plus one year clamps to Feb 28', () {
        expect(DateTime(2020, 2, 29).addYears(1), DateTime(2021, 2, 28));
      });

      test('crosses into a leap year keeping the day', () {
        expect(DateTime(2023, 3, 1).addYears(1), DateTime(2024, 3, 1));
      });
    });

    group('addMonths', () {
      test('returns same instance for 0 months', () {
        final DateTime d = DateTime(2023, 6, 15);
        expect(d.addMonths(0), same(d));
      });

      test('adds months within the same year', () {
        expect(DateTime(2023, 6, 15).addMonths(2), DateTime(2023, 8, 15));
      });

      test('crosses year boundary', () {
        expect(DateTime(2023, 11, 15).addMonths(2), DateTime(2024, 1, 15));
      });

      test('Jan 31 plus one month clamps to end of February', () {
        expect(DateTime(2023, 1, 31).addMonths(1), DateTime(2023, 2, 28));
      });
    });

    group('addDays', () {
      test('returns same instance for 0 days', () {
        final DateTime d = DateTime(2023, 6, 15);
        expect(d.addDays(0), same(d));
      });

      test('adds days crossing a month boundary', () {
        expect(DateTime(2023, 1, 30).addDays(3), DateTime(2023, 2, 2));
      });

      test('adds days across leap day', () {
        expect(DateTime(2024, 2, 28).addDays(1), DateTime(2024, 2, 29));
      });
    });

    group('addHours', () {
      test('returns same instance for 0 hours', () {
        final DateTime d = DateTime(2023, 6, 15, 10);
        expect(d.addHours(0), same(d));
      });

      test('adds hours crossing midnight', () {
        expect(DateTime(2023, 6, 15, 23).addHours(2), DateTime(2023, 6, 16, 1));
      });
    });

    group('addMinutes', () {
      test('returns same instance for 0 minutes', () {
        final DateTime d = DateTime(2023, 6, 15, 10, 30);
        expect(d.addMinutes(0), same(d));
      });

      test('adds minutes crossing the hour', () {
        expect(DateTime(2023, 6, 15, 10, 50).addMinutes(20), DateTime(2023, 6, 15, 11, 10));
      });
    });

    group('subtractMinutes', () {
      test('returns same instance for 0 minutes', () {
        final DateTime d = DateTime(2023, 6, 15, 10, 30);
        expect(d.subtractMinutes(0), same(d));
      });

      test('subtracts minutes crossing the hour backwards', () {
        expect(DateTime(2023, 6, 15, 11, 10).subtractMinutes(20), DateTime(2023, 6, 15, 10, 50));
      });
    });

    group('subtractHours', () {
      test('returns same instance for 0 hours', () {
        final DateTime d = DateTime(2023, 6, 15, 10);
        expect(d.subtractHours(0), same(d));
      });

      test('subtracts hours crossing midnight backwards', () {
        expect(DateTime(2023, 6, 16, 1).subtractHours(2), DateTime(2023, 6, 15, 23));
      });
    });

    group('subtractMonths', () {
      test('returns same instance for 0 months', () {
        final DateTime d = DateTime(2023, 6, 15);
        expect(d.subtractMonths(0), same(d));
      });

      test('subtracts months crossing year boundary backwards', () {
        expect(DateTime(2024, 1, 15).subtractMonths(2), DateTime(2023, 11, 15));
      });
    });

    group('subtractYears', () {
      test('returns same instance for 0 years', () {
        final DateTime d = DateTime(2023, 6, 15);
        expect(d.subtractYears(0), same(d));
      });

      test('subtracts one year', () {
        expect(DateTime(2024, 6, 15).subtractYears(1), DateTime(2023, 6, 15));
      });

      test('Feb 29 minus one year clamps to Feb 28', () {
        expect(DateTime(2020, 2, 29).subtractYears(1), DateTime(2019, 2, 28));
      });
    });

    group('subtractDays', () {
      test('returns same instance for null days', () {
        final DateTime d = DateTime(2023, 6, 15);
        expect(d.subtractDays(null), same(d));
      });

      test('returns same instance for 0 days', () {
        final DateTime d = DateTime(2023, 6, 15);
        expect(d.subtractDays(0), same(d));
      });

      test('subtracts days crossing a month boundary backwards', () {
        expect(DateTime(2023, 2, 2).subtractDays(3), DateTime(2023, 1, 30));
      });

      test('subtracts across leap day backwards', () {
        expect(DateTime(2024, 2, 29).subtractDays(1), DateTime(2024, 2, 28));
      });
    });
  });
}
