import 'dart:async' show Completer;

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/cancellation_token_utils.dart';

void main() {
  group('CancellationException', () {
    test('should render without a reason', () {
      expect(const CancellationException().toString(), equals('CancellationException'));
    });

    test('should render with a reason', () {
      expect(
        const CancellationException('timeout').toString(),
        equals('CancellationException: timeout'),
      );
    });
  });

  group('CancellationToken', () {
    test('should start uncancelled', () {
      final CancellationToken token = CancellationToken();

      expect(token.isCancelled, isFalse);
      expect(token.reason, isNull);
    });

    test('should latch state and reason on cancel', () {
      final CancellationToken token = CancellationToken()..cancel('done');

      expect(token.isCancelled, isTrue);
      expect(token.reason, equals('done'));
    });

    group('throwIfCancelled', () {
      test('should not throw before cancel', () {
        final CancellationToken token = CancellationToken();

        expect(token.throwIfCancelled, returnsNormally);
      });

      test('should throw after cancel', () {
        final CancellationToken token = CancellationToken()..cancel('stop');

        expect(token.throwIfCancelled, throwsA(isA<CancellationException>()));
      });
    });

    group('whenCancelled', () {
      test('should complete when the token is cancelled', () async {
        final CancellationToken token = CancellationToken();
        final Future<void> done = token.whenCancelled;

        token.cancel();

        await expectLater(done, completes);
      });
    });

    group('onCancel', () {
      test('should fire exactly once even if cancel is called twice', () async {
        final CancellationToken token = CancellationToken();
        int fired = 0;
        token.onCancel(() => fired++);

        token
          ..cancel()
          ..cancel();
        // Let any scheduled microtasks drain before asserting.
        await Future<void>.delayed(Duration.zero);

        expect(fired, equals(1));
      });

      test('should fire when registered after the token is already cancelled', () async {
        final CancellationToken token = CancellationToken()..cancel();
        int fired = 0;

        token.onCancel(() => fired++);
        // The already-cancelled path schedules a microtask; drain it.
        await Future<void>.delayed(Duration.zero);

        expect(fired, equals(1));
      });
    });
  });

  group('runCancellable', () {
    test('should return the task value when not cancelled', () async {
      final CancellationToken token = CancellationToken();

      final int value = await runCancellable(token, () async => 42);

      expect(value, equals(42));
    });

    test('should throw CancellationException when cancelled first', () async {
      final CancellationToken token = CancellationToken();
      // A task that never completes, so cancellation must win the race.
      final Future<int> result = runCancellable(
        token,
        () => Completer<int>().future,
      );

      token.cancel('aborted');

      await expectLater(result, throwsA(isA<CancellationException>()));
    });

    test('should propagate the cancellation reason', () async {
      final CancellationToken token = CancellationToken();
      final Future<int> result = runCancellable(
        token,
        () => Completer<int>().future,
      );

      token.cancel('aborted');

      await expectLater(
        result,
        throwsA(
          isA<CancellationException>().having(
            (CancellationException e) => e.reason,
            'reason',
            'aborted',
          ),
        ),
      );
    });

    test('should forward a task error when the task fails first', () async {
      final CancellationToken token = CancellationToken();

      final Future<int> result = runCancellable(
        token,
        () async => throw StateError('boom'),
      );

      await expectLater(result, throwsA(isA<StateError>()));
    });
  });
}
