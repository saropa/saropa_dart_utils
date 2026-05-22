import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/async_more_utils.dart';

void main() {
  group('race', () {
    test('returns the first future to complete', () async {
      final int r = await race<int>(<Future<int>>[
        Future<int>.delayed(const Duration(milliseconds: 50), () => 1),
        Future<int>.value(2),
      ]);
      expect(r, 2);
    });

    test('completes with an error if the fastest future fails', () async {
      await expectLater(
        race<int>(<Future<int>>[
          Future<int>.error(StateError('boom')),
          Future<int>.delayed(const Duration(milliseconds: 50), () => 1),
        ]),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('allSettled', () {
    test('returns values for all-successful futures in order', () async {
      final List<Object?> results = await allSettled<int>(<Future<int>>[
        Future<int>.value(1),
        Future<int>.value(2),
        Future<int>.value(3),
      ]);
      expect(results, <int>[1, 2, 3]);
    });

    test('captures errors as [error, stackTrace] without throwing', () async {
      final err = StateError('nope');
      final List<Object?> results = await allSettled<int>(<Future<int>>[
        Future<int>.value(1),
        Future<int>.error(err),
      ]);
      expect(results[0], 1);
      expect(results[1], isA<List<Object>>());
      final pair = results[1]! as List<Object>;
      expect(pair[0], same(err));
      expect(pair[1], isA<StackTrace>());
    });

    test('returns an empty list for no futures', () async {
      expect(await allSettled<int>(<Future<int>>[]), isEmpty);
    });
  });

  group('retryTimes', () {
    test('returns on first success without extra attempts', () async {
      int calls = 0;
      final int r = await retryTimes<int>(() async {
        calls++;
        return 7;
      }, 3);
      expect(r, 7);
      expect(calls, 1);
    });

    test('retries until success', () async {
      int calls = 0;
      final int r = await retryTimes<int>(() async {
        calls++;
        if (calls < 3) throw Exception('fail');
        return 99;
      }, 5);
      expect(r, 99);
      expect(calls, 3);
    });

    test('rethrows after exhausting the allowed attempts', () async {
      int calls = 0;
      await expectLater(
        retryTimes<int>(() async {
          calls++;
          throw StateError('always');
        }, 3),
        throwsA(isA<StateError>()),
      );
      expect(calls, 3);
    });
  });
}
