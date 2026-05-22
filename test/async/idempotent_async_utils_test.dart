import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/idempotent_async_utils.dart';

void main() {
  group('IdempotentAsyncUtils', () {
    test('concurrent calls with the same key share one future', () async {
      final IdempotentAsyncUtils dedupe = IdempotentAsyncUtils();
      int calls = 0;

      Future<int> work() => dedupe.run<int>('k', () async {
        calls++;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return 7;
      });

      final Future<int> a = work();
      final Future<int> b = work();
      final List<int> results = await Future.wait(<Future<int>>[a, b]);
      expect(results, <int>[7, 7]);
      expect(calls, 1); // function ran once
    });

    test('different keys run independently', () async {
      final IdempotentAsyncUtils dedupe = IdempotentAsyncUtils();
      int calls = 0;
      Future<int> work(String key) => dedupe.run<int>(key, () async {
        calls++;
        return key.length;
      });

      final List<int> results = await Future.wait(<Future<int>>[work('a'), work('bb')]);
      expect(results, <int>[1, 2]);
      expect(calls, 2);
    });

    test('a new call after completion re-runs the function', () async {
      final IdempotentAsyncUtils dedupe = IdempotentAsyncUtils();
      int calls = 0;
      Future<int> work() => dedupe.run<int>('k', () async => ++calls);

      expect(await work(), 1);
      // The first future completed and was removed, so this re-runs.
      expect(await work(), 2);
      expect(calls, 2);
    });

    test('removes the entry after the shared future completes', () async {
      final IdempotentAsyncUtils dedupe = IdempotentAsyncUtils();
      final Future<int> f = dedupe.run<int>('k', () async => 1);
      expect(dedupe.toString(), 'IdempotentAsyncUtils(inFlight: 1)');
      await f;
      // whenComplete callback runs as a microtask; let it drain.
      await Future<void>.value();
      expect(dedupe.toString(), 'IdempotentAsyncUtils(inFlight: 0)');
    });
  });
}
