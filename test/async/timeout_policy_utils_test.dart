import 'dart:async' show TimeoutException;

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/timeout_policy_utils.dart';

void main() {
  group('withTimeout', () {
    test('returns the result when fn completes before the timeout', () async {
      final int r = await withTimeout<int>(
        () async => 42,
        const Duration(seconds: 1),
      );
      expect(r, 42);
    });

    test('returns the fallback when fn times out', () async {
      final int r = await withTimeout<int>(
        () => Future<int>.delayed(const Duration(hours: 1), () => 1),
        const Duration(milliseconds: 5),
        fallback: -1,
      );
      expect(r, -1);
    });

    test('rethrows TimeoutException when no fallback is provided', () async {
      await expectLater(
        withTimeout<int>(
          () => Future<int>.delayed(const Duration(hours: 1), () => 1),
          const Duration(milliseconds: 5),
        ),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('propagates errors thrown by fn before any timeout', () async {
      await expectLater(
        withTimeout<int>(
          () async => throw StateError('boom'),
          const Duration(seconds: 1),
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
