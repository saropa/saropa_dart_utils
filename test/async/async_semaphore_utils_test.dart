import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/async_semaphore_utils.dart';

void main() {
  group('AsyncSemaphoreUtils', () {
    test('permits getter reflects the configured value', () {
      expect(AsyncSemaphoreUtils(3).permits, 3);
    });

    test('a single permit serializes run blocks', () async {
      final AsyncSemaphoreUtils sem = AsyncSemaphoreUtils(1);
      final List<String> log = <String>[];

      Future<void> task(String id) => sem.run(() async {
        log.add('start-$id');
        await Future<void>.delayed(const Duration(milliseconds: 5));
        log.add('end-$id');
      });

      await Future.wait(<Future<void>>[task('A'), task('B')]);
      expect(log, <String>['start-A', 'end-A', 'start-B', 'end-B']);
    });

    test('allows up to [permits] concurrent holders', () async {
      final AsyncSemaphoreUtils sem = AsyncSemaphoreUtils(2);
      int active = 0;
      int maxActive = 0;

      Future<void> task() => sem.run(() async {
        active++;
        if (active > maxActive) maxActive = active;
        await Future<void>.delayed(const Duration(milliseconds: 5));
        active--;
      });

      await Future.wait(<Future<void>>[task(), task(), task(), task()]);
      // Concurrency must never exceed the permit count.
      expect(maxActive, 2);
    });

    test('run returns the callback result', () async {
      final AsyncSemaphoreUtils sem = AsyncSemaphoreUtils(1);
      expect(await sem.run<int>(() async => 11), 11);
    });

    test('release without a matching acquire throws StateError', () {
      // Guards the permit invariant: over-release would let the semaphore admit
      // more than `permits` holders.
      final AsyncSemaphoreUtils sem = AsyncSemaphoreUtils(1);
      expect(sem.release, throwsA(isA<StateError>()));
    });

    test('run releases the permit even when the callback throws', () async {
      final AsyncSemaphoreUtils sem = AsyncSemaphoreUtils(1);
      await expectLater(
        sem.run<void>(() async => throw StateError('boom')),
        throwsA(isA<StateError>()),
      );
      // Permit must be reusable: this run completes only if released.
      expect(await sem.run<int>(() async => 5), 5);
    });

    test('acquire blocks once permits are exhausted and unblocks on release', () async {
      final AsyncSemaphoreUtils sem = AsyncSemaphoreUtils(1);
      await sem.acquire();
      var second = false;
      final Future<void> waiting = sem.acquire().then((_) => second = true);
      await Future<void>.value();
      expect(second, isFalse); // blocked

      sem.release();
      await waiting;
      expect(second, isTrue);
    });

    test('toString reports permits and available count', () async {
      final AsyncSemaphoreUtils sem = AsyncSemaphoreUtils(2);
      expect(sem.toString(), 'AsyncSemaphoreUtils(permits: 2, available: 2)');
      await sem.acquire();
      expect(sem.toString(), 'AsyncSemaphoreUtils(permits: 2, available: 1)');
    });
  });
}
