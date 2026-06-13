import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/resource_pool_utils.dart';

void main() {
  group('ResourcePool', () {
    test('should create lazily and reuse an idle resource', () async {
      int created = 0;
      final ResourcePool<int> pool = ResourcePool<int>(
        create: () async => ++created,
        maxSize: 2,
      );

      final int first = await pool.use((int r) async => r);
      final int second = await pool.use((int r) async => r);

      // Sequential uses reuse the single idle resource; only one is ever created.
      expect(created, equals(1));
      expect(first, equals(1));
      expect(second, equals(1));
      expect(pool.idleCount, equals(1));
    });

    test('should create up to maxSize for concurrent borrowers', () async {
      int created = 0;
      final ResourcePool<int> pool = ResourcePool<int>(
        create: () async => ++created,
        maxSize: 2,
      );
      final Completer<void> hold = Completer<void>();

      // Two concurrent borrowers each hold a resource until `hold` completes.
      final Future<int> a = pool.use((int r) async {
        await hold.future;
        return r;
      });
      final Future<int> b = pool.use((int r) async {
        await hold.future;
        return r;
      });
      await Future<void>.delayed(Duration.zero);

      expect(pool.inUseCount, equals(2));
      expect(created, equals(2));

      hold.complete();
      await Future.wait(<Future<int>>[a, b]);
    });

    test('should make a third borrower wait until a resource is released', () async {
      final ResourcePool<int> pool = ResourcePool<int>(
        create: () async => 0,
        maxSize: 1,
      );
      final Completer<void> hold = Completer<void>();
      final List<String> order = <String>[];

      final Future<void> first = pool.use((int r) async {
        order.add('first-start');
        await hold.future;
        order.add('first-end');
      });
      final Future<void> second = pool.use((int r) async => order.add('second'));
      await Future<void>.delayed(Duration.zero);

      // Second is queued behind the single in-use resource.
      expect(pool.waitingCount, equals(1));
      expect(order, equals(<String>['first-start']));

      hold.complete();
      await Future.wait(<Future<void>>[first, second]);

      expect(order, equals(<String>['first-start', 'first-end', 'second']));
    });

    test('should release the resource even when the action throws', () async {
      final ResourcePool<int> pool = ResourcePool<int>(
        create: () async => 1,
        maxSize: 1,
      );

      await expectLater(
        pool.use<void>((int r) async => throw StateError('boom')),
        throwsStateError,
      );
      // The slot is freed despite the failure, so the next borrow succeeds.
      expect(await pool.use((int r) async => r), equals(1));
      expect(pool.idleCount, equals(1));
    });

    test('should roll back the count when creation fails', () async {
      bool fail = true;
      final ResourcePool<int> pool = ResourcePool<int>(
        create: () async {
          if (fail) {
            throw StateError('cannot create');
          }
          return 42;
        },
        maxSize: 1,
      );

      await expectLater(pool.acquire(), throwsStateError);
      // The failed creation did not consume the only slot.
      fail = false;
      expect(await pool.use((int r) async => r), equals(42));
    });

    test('should dispose idle resources on close', () async {
      final List<int> disposed = <int>[];
      final ResourcePool<int> pool = ResourcePool<int>(
        create: () async => 7,
        maxSize: 1,
        onDispose: (int r) async => disposed.add(r),
      );

      await pool.use((int r) async => r); // creates then returns to idle
      await pool.close();

      expect(disposed, equals(<int>[7]));
    });

    test('should reject acquire after close', () async {
      final ResourcePool<int> pool = ResourcePool<int>(
        create: () async => 1,
        maxSize: 1,
      );
      await pool.close();

      await expectLater(pool.acquire(), throwsStateError);
    });

    test('should fail waiting borrowers when closed', () async {
      final ResourcePool<int> pool = ResourcePool<int>(
        create: () async => 1,
        maxSize: 1,
      );
      final Completer<void> hold = Completer<void>();

      final Future<void> inUse = pool.use((int r) async => hold.future);
      await Future<void>.delayed(Duration.zero);
      final Future<int> waiter = pool.acquire(); // queued behind the in-use one

      final Future<void> closing = pool.close();

      await expectLater(waiter, throwsStateError);
      hold.complete();
      await inUse;
      await closing;
    });

    test('should reject a maxSize below 1', () {
      expect(
        () => ResourcePool<int>(create: () async => 1, maxSize: 0),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
