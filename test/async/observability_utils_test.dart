import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/observability_utils.dart';

void main() {
  group('observeAsync', () {
    test('returns the result and fires onSuccess with the value', () async {
      int? seen;
      Duration? elapsed;
      final int result = await observeAsync(
        () async => 7,
        onSuccess: (Duration d, int r) {
          seen = r;
          elapsed = d;
        },
      );
      expect(result, 7);
      expect(seen, 7);
      expect(elapsed, isNotNull);
    });

    test('rethrows and fires onError, never onSuccess', () async {
      bool successCalled = false;
      Object? caught;
      await expectLater(
        observeAsync<int>(
          () async => throw StateError('boom'),
          onSuccess: (Duration d, int r) => successCalled = true,
          onError: (Duration d, Object e, StackTrace s) => caught = e,
        ),
        throwsStateError,
      );
      expect(successCalled, isFalse);
      expect(caught, isA<StateError>());
    });

    test('works without hooks', () async {
      expect(await observeAsync(() async => 'ok'), 'ok');
    });
  });

  group('observeSync', () {
    test('returns the result and fires onSuccess', () {
      int? seen;
      final int result = observeSync(() => 5, onSuccess: (Duration d, int r) => seen = r);
      expect(result, 5);
      expect(seen, 5);
    });

    test('rethrows and fires onError', () {
      Object? caught;
      expect(
        () => observeSync<int>(
          () => throw ArgumentError('bad'),
          onError: (Duration d, Object e, StackTrace s) => caught = e,
        ),
        throwsArgumentError,
      );
      expect(caught, isA<ArgumentError>());
    });
  });
}
