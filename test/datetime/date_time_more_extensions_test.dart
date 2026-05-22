// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/date_time_more_extensions.dart';

void main() {
  group('DateTimeMoreExtensions', () {
    group('isSameDay', () {
      test('true when y/m/d match ignoring time', () {
        expect(DateTime(2023, 6, 15, 1).isSameDay(DateTime(2023, 6, 15, 23)), isTrue);
      });

      test('false when day differs', () {
        expect(DateTime(2023, 6, 15).isSameDay(DateTime(2023, 6, 16)), isFalse);
      });
    });

    group('isMorning', () {
      test('true at 5am (lower boundary)', () {
        expect(DateTime(2023, 6, 15, 5).isMorning, isTrue);
      });

      test('true at 11am', () {
        expect(DateTime(2023, 6, 15, 11).isMorning, isTrue);
      });

      test('false at noon (upper boundary excluded)', () {
        expect(DateTime(2023, 6, 15, 12).isMorning, isFalse);
      });

      test('false at 4am (below lower boundary)', () {
        expect(DateTime(2023, 6, 15, 4).isMorning, isFalse);
      });
    });

    group('isAfternoon', () {
      test('true at noon (lower boundary)', () {
        expect(DateTime(2023, 6, 15, 12).isAfternoon, isTrue);
      });

      test('true at 4pm', () {
        expect(DateTime(2023, 6, 15, 16).isAfternoon, isTrue);
      });

      test('false at 5pm (upper boundary excluded)', () {
        expect(DateTime(2023, 6, 15, 17).isAfternoon, isFalse);
      });

      test('false at 11am', () {
        expect(DateTime(2023, 6, 15, 11).isAfternoon, isFalse);
      });
    });

    group('isEvening', () {
      test('true at 5pm (lower boundary)', () {
        expect(DateTime(2023, 6, 15, 17).isEvening, isTrue);
      });

      test('true at 4am (before morning)', () {
        expect(DateTime(2023, 6, 15, 4).isEvening, isTrue);
      });

      test('false at noon', () {
        expect(DateTime(2023, 6, 15, 12).isEvening, isFalse);
      });

      test('false at 5am', () {
        expect(DateTime(2023, 6, 15, 5).isEvening, isFalse);
      });
    });

    group('isWithinLastDays', () {
      test('true when exactly n days before now', () {
        expect(
          DateTime(2023, 6, 8).isWithinLastDays(7, DateTime(2023, 6, 15, 12)),
          isTrue,
        );
      });

      test('true for today', () {
        expect(
          DateTime(2023, 6, 15, 8).isWithinLastDays(7, DateTime(2023, 6, 15, 12)),
          isTrue,
        );
      });

      test('false when older than the window', () {
        expect(
          DateTime(2023, 6, 7).isWithinLastDays(7, DateTime(2023, 6, 15, 12)),
          isFalse,
        );
      });

      test('false when in the future relative to now', () {
        expect(
          DateTime(2023, 6, 16).isWithinLastDays(7, DateTime(2023, 6, 15, 12)),
          isFalse,
        );
      });
    });

    group('isWithinLastHours', () {
      test('true when within the window', () {
        expect(
          DateTime(2023, 6, 15, 10).isWithinLastHours(3, DateTime(2023, 6, 15, 12)),
          isTrue,
        );
      });

      test('true at exactly n hours before now', () {
        expect(
          DateTime(2023, 6, 15, 9).isWithinLastHours(3, DateTime(2023, 6, 15, 12)),
          isTrue,
        );
      });

      test('false just before the window', () {
        expect(
          DateTime(2023, 6, 15, 8, 59).isWithinLastHours(3, DateTime(2023, 6, 15, 12)),
          isFalse,
        );
      });

      test('false when after now', () {
        expect(
          DateTime(2023, 6, 15, 13).isWithinLastHours(3, DateTime(2023, 6, 15, 12)),
          isFalse,
        );
      });
    });
  });

  group('durationBetween', () {
    test('returns positive duration regardless of order', () {
      expect(
        durationBetween(DateTime(2020), DateTime(2020, 1, 2)),
        const Duration(days: 1),
      );
    });

    test('absolute value when arguments reversed', () {
      expect(
        durationBetween(DateTime(2020, 1, 2), DateTime(2020)),
        const Duration(days: 1),
      );
    });

    test('zero for identical instants', () {
      final DateTime d = DateTime(2020, 5, 5, 5, 5);
      expect(durationBetween(d, d), Duration.zero);
    });
  });

  group('monthsBetween', () {
    test('lists first day of each month inclusive', () {
      expect(
        monthsBetween(DateTime(2020, 1, 15), DateTime(2020, 3, 1)),
        <DateTime>[DateTime(2020), DateTime(2020, 2), DateTime(2020, 3)],
      );
    });

    test('single month when start and end share a month', () {
      expect(
        monthsBetween(DateTime(2020, 6, 1), DateTime(2020, 6, 30)),
        <DateTime>[DateTime(2020, 6)],
      );
    });

    test('crosses a year boundary', () {
      expect(
        monthsBetween(DateTime(2020, 11, 20), DateTime(2021, 1, 5)),
        <DateTime>[DateTime(2020, 11), DateTime(2020, 12), DateTime(2021)],
      );
    });
  });

  group('yearsBetween', () {
    test('inclusive range of years', () {
      expect(yearsBetween(DateTime(2020), DateTime(2023)), <int>[2020, 2021, 2022, 2023]);
    });

    test('single year', () {
      expect(yearsBetween(DateTime(2020, 1, 1), DateTime(2020, 12, 31)), <int>[2020]);
    });
  });
}
