import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/rate_limit_schedule_utils.dart';

void main() {
  group('RateLimitSchedule', () {
    final DateTime base = DateTime(2026, 6, 12, 9);
    DateTime at(int minutes) => base.add(Duration(minutes: minutes));

    test('should pass through requests that already satisfy the limits', () {
      final RateLimitSchedule s = RateLimitSchedule(
        maxPerPeriod: 2,
        period: const Duration(hours: 1),
      );

      final List<DateTime> out = s.shape(<DateTime>[at(0), at(30), at(90)]);

      expect(out, equals(<DateTime>[at(0), at(30), at(90)]));
    });

    test('should push the third event past the window when over quota', () {
      final RateLimitSchedule s = RateLimitSchedule(
        maxPerPeriod: 2,
        period: const Duration(hours: 1),
      );

      // Three at the same instant: the first two fit the window, the third
      // slips to one period after the oldest in-window fire.
      final List<DateTime> out = s.shape(<DateTime>[at(0), at(0), at(0)]);

      expect(out, equals(<DateTime>[at(0), at(0), at(60)]));
    });

    test('should enforce a cooldown between consecutive events', () {
      final RateLimitSchedule s = RateLimitSchedule(
        maxPerPeriod: 100,
        period: const Duration(days: 1),
        cooldown: Duration(minutes: 60),
      );

      final List<DateTime> out = s.shape(<DateTime>[at(0), at(0), at(0)]);

      expect(out, equals(<DateTime>[at(0), at(60), at(120)]));
    });

    test('should apply cooldown and window quota together', () {
      final RateLimitSchedule s = RateLimitSchedule(
        maxPerPeriod: 2,
        period: const Duration(hours: 1),
        cooldown: Duration(minutes: 20),
      );

      final List<DateTime> out = s.shape(<DateTime>[at(0), at(0), at(0), at(0)]);

      expect(out, equals(<DateTime>[at(0), at(20), at(60), at(80)]));
    });

    test('should never move an event earlier than its request', () {
      final RateLimitSchedule s = RateLimitSchedule(
        maxPerPeriod: 1,
        period: const Duration(minutes: 10),
      );

      final List<DateTime> out = s.shape(<DateTime>[at(0), at(100)]);

      // The second request is already well past any limit, so it is unchanged.
      expect(out, equals(<DateTime>[at(0), at(100)]));
    });

    test('should return an empty schedule for no requests', () {
      final RateLimitSchedule s = RateLimitSchedule(
        maxPerPeriod: 1,
        period: const Duration(minutes: 1),
      );

      expect(s.shape(<DateTime>[]), isEmpty);
    });

    test('should output non-decreasing fire times', () {
      final RateLimitSchedule s = RateLimitSchedule(
        maxPerPeriod: 3,
        period: const Duration(minutes: 30),
        cooldown: Duration(minutes: 5),
      );

      final List<DateTime> out = s.shape(<DateTime>[
        for (int i = 0; i < 12; i++) at(i * 2),
      ]);

      for (int i = 1; i < out.length; i++) {
        expect(out[i].isBefore(out[i - 1]), isFalse, reason: 'index $i went backwards');
      }
    });

    test('should assert on invalid configuration', () {
      expect(
        () => RateLimitSchedule(maxPerPeriod: 0, period: const Duration(minutes: 1)),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => RateLimitSchedule(maxPerPeriod: 1, period: Duration.zero),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => RateLimitSchedule(
          maxPerPeriod: 1,
          period: const Duration(minutes: 1),
          cooldown: Duration(minutes: -1),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
