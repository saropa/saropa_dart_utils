import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/cancel_previous_exception.dart';

void main() {
  group('cancelPrevious', () {
    test('returns the result when not superseded', () async {
      final Future<int> Function() wrapped = cancelPrevious<int>(() async => 42);
      expect(await wrapped(), 42);
    });

    test('a superseded earlier call throws CancelPreviousException', () async {
      int started = 0;
      final Future<int> Function() wrapped = cancelPrevious<int>(() async {
        final int id = ++started;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return id;
      });

      final Future<int> first = wrapped();
      final Future<int> second = wrapped();

      // The newer invocation wins; the older one is cancelled.
      await expectLater(first, throwsA(isA<CancelPreviousException>()));
      expect(await second, 2);
    });

    test('the latest call always resolves to its own result', () async {
      final Future<int> Function() wrapped = cancelPrevious<int>(() async {
        await Future<void>.delayed(const Duration(milliseconds: 5));
        return DateTime.now().microsecond;
      });
      wrapped().catchError((_) => -1); // superseded
      final Future<int> latest = wrapped();
      expect(await latest, isA<int>());
    });
  });

  group('CancelPreviousException', () {
    test('is an Exception', () {
      expect(CancelPreviousException(), isA<Exception>());
    });
  });
}
