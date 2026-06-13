import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/rate_limiter_utils.dart';

void main() {
  group('TokenBucketRateLimiter', () {
    // A mutable virtual clock so refill is deterministic (no wall-clock waits).
    late DateTime now;
    DateTime clock() => now;

    setUp(() => now = DateTime(2026));

    test('should allow an initial burst up to capacity', () {
      final TokenBucketRateLimiter limiter = TokenBucketRateLimiter(
        tokensPerSecond: 1,
        capacity: 3,
        now: clock,
      );

      expect(limiter.tryAcquire(), isTrue);
      expect(limiter.tryAcquire(), isTrue);
      expect(limiter.tryAcquire(), isTrue);
      // Bucket drained; the 4th is denied (no time has passed to refill).
      expect(limiter.tryAcquire(), isFalse);
    });

    test('should refill at the configured rate as the clock advances', () {
      final TokenBucketRateLimiter limiter = TokenBucketRateLimiter(
        tokensPerSecond: 2,
        capacity: 2,
        now: clock,
      );

      expect(limiter.tryAcquire(2), isTrue); // drain
      expect(limiter.tryAcquire(), isFalse);

      now = now.add(const Duration(milliseconds: 500)); // 0.5s * 2/s = 1 token
      expect(limiter.tryAcquire(), isTrue);
      expect(limiter.tryAcquire(), isFalse);
    });

    test('should cap refill at capacity (no overflow)', () {
      final TokenBucketRateLimiter limiter = TokenBucketRateLimiter(
        tokensPerSecond: 5,
        capacity: 3,
        now: clock,
      );

      expect(limiter.tryAcquire(3), isTrue); // drain to 0
      now = now.add(const Duration(seconds: 10)); // would be 50 tokens, capped at 3

      expect(limiter.availableTokens(), equals(3));
    });

    test('should not partially spend when tokens are insufficient', () {
      final TokenBucketRateLimiter limiter = TokenBucketRateLimiter(
        tokensPerSecond: 1,
        capacity: 5,
        now: clock,
      );

      expect(limiter.tryAcquire(2), isTrue); // 5 -> 3
      expect(limiter.tryAcquire(4), isFalse); // needs 4, has 3: denied, no deduction
      expect(limiter.availableTokens(), equals(3));
    });

    group('timeUntilAvailable', () {
      test('should be zero when tokens are available', () {
        final TokenBucketRateLimiter limiter = TokenBucketRateLimiter(
          tokensPerSecond: 1,
          capacity: 2,
          now: clock,
        );

        expect(limiter.timeUntilAvailable(), equals(Duration.zero));
      });

      test('should report the wait for the token deficit', () {
        final TokenBucketRateLimiter limiter = TokenBucketRateLimiter(
          tokensPerSecond: 2,
          capacity: 4,
          now: clock,
        );

        expect(limiter.tryAcquire(4), isTrue); // drain
        // Need 1 token at 2/s => 0.5s.
        expect(limiter.timeUntilAvailable(), equals(const Duration(milliseconds: 500)));
      });
    });

    group('input validation', () {
      test('should reject acquiring more than capacity', () {
        final TokenBucketRateLimiter limiter = TokenBucketRateLimiter(
          tokensPerSecond: 1,
          capacity: 2,
          now: clock,
        );

        expect(() => limiter.tryAcquire(3), throwsArgumentError);
      });

      test('should reject acquiring fewer than 1', () {
        final TokenBucketRateLimiter limiter = TokenBucketRateLimiter(
          tokensPerSecond: 1,
          capacity: 2,
          now: clock,
        );

        expect(() => limiter.tryAcquire(0), throwsArgumentError);
      });

      test('should assert on a non-positive rate', () {
        expect(
          () => TokenBucketRateLimiter(tokensPerSecond: 0, capacity: 1),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    test('should not accrue when the clock steps backward', () {
      final TokenBucketRateLimiter limiter = TokenBucketRateLimiter(
        tokensPerSecond: 1,
        capacity: 5,
        now: clock,
      );

      expect(limiter.tryAcquire(5), isTrue); // drain
      now = now.subtract(const Duration(seconds: 10)); // clock regression

      expect(limiter.availableTokens(), equals(0));
    });
  });
}
