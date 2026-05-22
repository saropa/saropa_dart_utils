import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/async_barrier_utils.dart';

void main() {
  group('AsyncBarrierUtils', () {
    test('factory throws ArgumentError when count < 1', () {
      expect(() => AsyncBarrierUtils(0), throwsArgumentError);
      expect(() => AsyncBarrierUtils(-3), throwsArgumentError);
    });

    test('count getter reflects the configured value', () {
      expect(AsyncBarrierUtils(3).count, 3);
    });

    test('future completes after exactly count signals', () async {
      final AsyncBarrierUtils barrier = AsyncBarrierUtils(3);
      var completed = false;
      // Listen before signalling so the completer exists when signals arrive.
      final Future<void> done = barrier.future.then((_) => completed = true);

      barrier.signal();
      await Future<void>.value(); // let microtasks drain
      expect(completed, isFalse);

      barrier.signal();
      await Future<void>.value();
      expect(completed, isFalse);

      barrier.signal();
      await done;
      expect(completed, isTrue);
    });

    test('future completes immediately when signals arrive before listening', () async {
      final AsyncBarrierUtils barrier = AsyncBarrierUtils(2);
      barrier.signal();
      barrier.signal();
      // Accessing future after the count is exhausted still completes.
      await barrier.future;
      expect(barrier.toString(), contains('remaining: 0'));
    });

    test(
      'signalling more than count times does not throw',
      () async {
        final AsyncBarrierUtils barrier = AsyncBarrierUtils(1);
        final Future<void> done = barrier.future;
        barrier.signal();
        barrier.signal(); // remaining goes negative
        await done;
        expect(barrier.toString(), contains('count: 1'));
      },
    );

    test('toString reports count and remaining', () {
      final AsyncBarrierUtils barrier = AsyncBarrierUtils(2);
      expect(barrier.toString(), 'AsyncBarrierUtils(count: 2, remaining: 2)');
      barrier.signal();
      expect(barrier.toString(), 'AsyncBarrierUtils(count: 2, remaining: 1)');
    });
  });
}
