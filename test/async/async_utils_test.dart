import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/delay_utils.dart';
import 'package:saropa_dart_utils/async/memoize_future_utils.dart';
import 'package:saropa_dart_utils/async/retry_utils.dart';
import 'package:saropa_dart_utils/async/sequential_async_utils.dart';
import 'package:saropa_dart_utils/async/timeout_fallback_utils.dart';

void main() {
  group('delay', () {
    test('delays', () async {
      final DateTime t0 = DateTime.now();
      await delay(const Duration(milliseconds: 10));
      expect(DateTime.now().difference(t0).inMilliseconds >= 10, isTrue);
    });
  });
  group('memoizeFuture', () {
    test('caches result', () async {
      int calls = 0;
      final Future<int> Function() fn = memoizeFuture(() async => ++calls);
      expect(await fn(), 1);
      expect(await fn(), 1);
      expect(calls, 1);
    });
  });
  group('retryWithBackoff', () {
    test('succeeds after retry', () async {
      int attempts = 0;
      final int r = await retryWithBackoff(
        () async {
          attempts++;
          if (attempts < 2) throw Exception('fail');
          return 42;
        },
        maxAttempts: 3,
        initialDelay: Duration.zero,
      );
      expect(r, 42);
      expect(attempts, 2);
    });
  });
  group('mapSequential', () {
    test('runs in order', () async {
      final List<int> order = <int>[];
      final List<int> out = await mapSequential(<int>[1, 2, 3], (int x) async {
        order.add(x);
        return x * 2;
      });
      expect(out, <int>[2, 4, 6]);
      expect(order, <int>[1, 2, 3]);
    });
  });
  group('timeoutWithFallback', () {
    test('returns fallback on timeout', () async {
      final int r = await timeoutWithFallback(
        future: Future<int>.delayed(const Duration(hours: 1), () => 1),
        timeout: const Duration(milliseconds: 5),
        fallback: -1,
      );
      expect(r, -1);
    });
  });
}
