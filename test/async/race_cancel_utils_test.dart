import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/race_cancel_utils.dart';

void main() {
  group('raceFirst', () {
    test('returns the result of the first producer to succeed', () async {
      final int r = await raceFirst<int>(<Future<int> Function()>[
        () => Future<int>.delayed(const Duration(milliseconds: 50), () => 1),
        () => Future<int>.value(2),
      ]);
      expect(r, 2);
    });

    test('ignores a fast failure and returns a later success', () async {
      final int r = await raceFirst<int>(<Future<int> Function()>[
        () => Future<int>.error(StateError('fast fail')),
        () => Future<int>.delayed(const Duration(milliseconds: 10), () => 99),
      ]);
      expect(r, 99);
    });

    test('throws StateError only when every producer fails', () async {
      await expectLater(
        raceFirst<int>(<Future<int> Function()>[
          () => Future<int>.error(Exception('a')),
          () => Future<int>.error(Exception('b')),
        ]),
        throwsA(isA<StateError>()),
      );
    });

    test('the first success wins over a slower success', () async {
      final int r = await raceFirst<int>(<Future<int> Function()>[
        () => Future<int>.delayed(const Duration(milliseconds: 30), () => 1),
        () => Future<int>.delayed(const Duration(milliseconds: 5), () => 2),
      ]);
      expect(r, 2);
    });
  });
}
