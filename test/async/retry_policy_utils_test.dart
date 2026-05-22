import 'dart:math' show Random;

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/retry_policy_utils.dart';

void main() {
  group('default constants', () {
    test('have their documented values', () {
      expect(retryPolicyDefaultDelay, const Duration(milliseconds: 100));
      expect(retryPolicyDefaultBackoffBase, const Duration(milliseconds: 100));
      expect(retryPolicyDefaultBackoffJitter, const Duration(milliseconds: 50));
    });
  });

  group('retryWithPolicy', () {
    test('returns immediately on first success', () async {
      int calls = 0;
      final int r = await retryWithPolicy<int>(() async {
        calls++;
        return 5;
      }, delay: Duration.zero);
      expect(r, 5);
      expect(calls, 1);
    });

    test('retries until success', () async {
      int calls = 0;
      final int r = await retryWithPolicy<int>(() async {
        calls++;
        if (calls < 3) throw Exception('fail');
        return 42;
      }, maxAttempts: 5, delay: Duration.zero);
      expect(r, 42);
      expect(calls, 3);
    });

    test('rethrows after maxAttempts failures', () async {
      int calls = 0;
      await expectLater(
        retryWithPolicy<int>(() async {
          calls++;
          throw StateError('always');
        }, maxAttempts: 3, delay: Duration.zero),
        throwsA(isA<StateError>()),
      );
      expect(calls, 3);
    });

    test('invokes onRetry with error and attempt number for each retry', () async {
      final List<int> attempts = <int>[];
      int calls = 0;
      await retryWithPolicy<int>(
        () async {
          calls++;
          if (calls < 3) throw Exception('fail');
          return 1;
        },
        maxAttempts: 5,
        delay: Duration.zero,
        onRetry: (Object e, int attempt) => attempts.add(attempt),
      );
      // Called once per retry (attempts 1 and 2), not on the final success.
      expect(attempts, <int>[1, 2]);
    });

    test('does not call onRetry on the final failing attempt', () async {
      int retries = 0;
      await expectLater(
        retryWithPolicy<int>(
          () async => throw Exception('x'),
          maxAttempts: 2,
          delay: Duration.zero,
          onRetry: (_, __) => retries++,
        ),
        throwsException,
      );
      // 2 attempts -> onRetry only after attempt 1.
      expect(retries, 1);
    });
  });

  group('retryWithJitter', () {
    test('returns on first success', () async {
      int calls = 0;
      final int r = await retryWithJitter<int>(
        () async {
          calls++;
          return 9;
        },
        base: Duration.zero,
        jitter: const Duration(milliseconds: 1),
      );
      expect(r, 9);
      expect(calls, 1);
    });

    test('retries until success using a seeded Random', () async {
      int calls = 0;
      final int r = await retryWithJitter<int>(
        () async {
          calls++;
          if (calls < 2) throw Exception('fail');
          return 3;
        },
        maxAttempts: 4,
        base: Duration.zero,
        jitter: const Duration(milliseconds: 1),
        random: Random(1),
      );
      expect(r, 3);
      expect(calls, 2);
    });

    test('rethrows after maxAttempts failures', () async {
      int calls = 0;
      await expectLater(
        retryWithJitter<int>(
          () async {
            calls++;
            throw StateError('boom');
          },
          maxAttempts: 3,
          base: Duration.zero,
          jitter: const Duration(milliseconds: 1),
          random: Random(7),
        ),
        throwsA(isA<StateError>()),
      );
      expect(calls, 3);
    });
  });
}
