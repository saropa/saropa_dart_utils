import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/async_mutex_utils.dart';

void main() {
  group('AsyncMutexUtils', () {
    test('acquire grants the lock immediately when free', () async {
      final AsyncMutexUtils mutex = AsyncMutexUtils();
      await mutex.acquire();
      expect(mutex.tryLock(), isFalse); // already held
    });

    test('tryLock succeeds once then fails until released', () {
      final AsyncMutexUtils mutex = AsyncMutexUtils();
      expect(mutex.tryLock(), isTrue);
      expect(mutex.tryLock(), isFalse);
      mutex.release();
      expect(mutex.tryLock(), isTrue);
    });

    test('serializes concurrent run blocks (no interleaving)', () async {
      final AsyncMutexUtils mutex = AsyncMutexUtils();
      final List<String> log = <String>[];

      Future<void> task(String id) => mutex.run(() async {
        log.add('start-$id');
        await Future<void>.delayed(const Duration(milliseconds: 5));
        log.add('end-$id');
      });

      await Future.wait(<Future<void>>[task('A'), task('B')]);
      // Critical sections must not interleave.
      expect(log, <String>['start-A', 'end-A', 'start-B', 'end-B']);
    });

    test('run returns the callback result and releases on success', () async {
      final AsyncMutexUtils mutex = AsyncMutexUtils();
      final int r = await mutex.run<int>(() async => 42);
      expect(r, 42);
      // Lock must be free again.
      expect(mutex.tryLock(), isTrue);
    });

    test('run releases the lock even when the callback throws', () async {
      final AsyncMutexUtils mutex = AsyncMutexUtils();
      await expectLater(
        mutex.run<void>(() async => throw StateError('boom')),
        throwsA(isA<StateError>()),
      );
      // finally-block release must have run.
      expect(mutex.tryLock(), isTrue);
    });

    test('release unblocks a single waiter in FIFO order', () async {
      final AsyncMutexUtils mutex = AsyncMutexUtils();
      final List<int> order = <int>[];
      await mutex.acquire(); // hold the lock

      final Future<void> w1 = mutex.acquire().then((_) => order.add(1));
      final Future<void> w2 = mutex.acquire().then((_) => order.add(2));
      await Future<void>.value();

      mutex.release(); // hands lock to first waiter
      await w1;
      mutex.release(); // hands lock to second waiter
      await w2;
      expect(order, <int>[1, 2]);
    });

    test('toString reports locked state and waiter count', () async {
      final AsyncMutexUtils mutex = AsyncMutexUtils();
      expect(mutex.toString(), 'AsyncMutexUtils(locked: false, waiters: 0)');
      await mutex.acquire();
      expect(mutex.toString(), 'AsyncMutexUtils(locked: true, waiters: 0)');
    });
  });
}
