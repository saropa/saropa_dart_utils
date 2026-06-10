import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/sliding_window_rate_limiter_utils.dart';

void main() {
  group('SlidingWindowRateLimiter', () {
    late DateTime now;
    DateTime clock() => now;

    setUp(() => now = DateTime(2026));

    SlidingWindowRateLimiter make({int limit = 3, Duration window = const Duration(seconds: 10)}) =>
        SlidingWindowRateLimiter(limit: limit, window: window, now: clock);

    test('should assert on a non-positive limit or window', () {
      expect(() => SlidingWindowRateLimiter(limit: 0, window: const Duration(seconds: 1)),
          throwsA(isA<AssertionError>()));
      expect(() => SlidingWindowRateLimiter(limit: 1, window: Duration.zero),
          throwsA(isA<AssertionError>()));
    });

    test('should allow up to the limit then deny', () {
      final SlidingWindowRateLimiter limiter = make(limit: 3);

      expect(limiter.tryAcquire(), isTrue);
      expect(limiter.tryAcquire(), isTrue);
      expect(limiter.tryAcquire(), isTrue);
      expect(limiter.tryAcquire(), isFalse); // 4th in the same window
      expect(limiter.currentCount(), equals(3));
    });

    test('should free a slot once the oldest event ages out of the window', () {
      final SlidingWindowRateLimiter limiter = make(limit: 2, window: const Duration(seconds: 10));

      now = DateTime(2026, 1, 1, 0, 0, 0); // t=0
      expect(limiter.tryAcquire(), isTrue);
      now = now.add(const Duration(seconds: 4)); // t=4
      expect(limiter.tryAcquire(), isTrue);
      expect(limiter.tryAcquire(), isFalse); // full (2 in window)

      now = now.add(const Duration(seconds: 7)); // t=11: the t=0 event (11s old) expired
      expect(limiter.tryAcquire(), isTrue);
      expect(limiter.currentCount(), equals(2)); // t=4 and t=11
    });

    test('should treat an event exactly window-old as expired (exclusive bound)', () {
      final SlidingWindowRateLimiter limiter = make(limit: 1, window: const Duration(seconds: 10));

      now = DateTime(2026, 1, 1, 0, 0, 0);
      expect(limiter.tryAcquire(), isTrue);
      now = now.add(const Duration(seconds: 10)); // exactly window later
      // The first event is exactly 10s old → aged out → a new one is allowed.
      expect(limiter.tryAcquire(), isTrue);
    });

    group('timeUntilAvailable', () {
      test('should be zero below the limit', () {
        final SlidingWindowRateLimiter limiter = make(limit: 2);
        limiter.tryAcquire();

        expect(limiter.timeUntilAvailable(), equals(Duration.zero));
      });

      test('should report the wait until the oldest event expires', () {
        final SlidingWindowRateLimiter limiter = make(limit: 1, window: const Duration(seconds: 10));

        now = DateTime(2026, 1, 1, 0, 0, 0);
        limiter.tryAcquire();
        now = now.add(const Duration(seconds: 3)); // 3s into the window

        // Oldest expires at t=10, now is t=3 → wait 7s.
        expect(limiter.timeUntilAvailable(), equals(const Duration(seconds: 7)));
      });
    });
  });
}
