import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/read_write_lock_utils.dart';

void main() {
  group('ReadWriteLock', () {
    test('should let multiple readers hold the lock concurrently', () async {
      final ReadWriteLock lock = ReadWriteLock();
      final Completer<void> gate = Completer<void>();

      final Future<void> r1 = lock.read(() => gate.future);
      final Future<void> r2 = lock.read(() => gate.future);
      await Future<void>.delayed(Duration.zero);

      expect(lock.activeReaders, equals(2));

      gate.complete();
      await Future.wait(<Future<void>>[r1, r2]);
      expect(lock.activeReaders, equals(0));
    });

    test('should block a reader while a writer holds the lock', () async {
      final ReadWriteLock lock = ReadWriteLock();
      final Completer<void> gate = Completer<void>();
      bool readRan = false;

      final Future<void> w = lock.write(() => gate.future);
      await Future<void>.delayed(Duration.zero);
      expect(lock.isWriteLocked, isTrue);

      final Future<void> r = lock.read(() async => readRan = true);
      await Future<void>.delayed(Duration.zero);
      expect(readRan, isFalse);
      expect(lock.waitingReaders, equals(1));

      gate.complete();
      await Future.wait(<Future<void>>[w, r]);
      expect(readRan, isTrue);
    });

    test('should serialize writes', () async {
      final ReadWriteLock lock = ReadWriteLock();
      final List<String> order = <String>[];
      final Completer<void> gate = Completer<void>();

      final Future<void> w1 = lock.write(() async {
        order.add('w1-start');
        await gate.future;
        order.add('w1-end');
      });
      await Future<void>.delayed(Duration.zero);
      final Future<void> w2 = lock.write(() async => order.add('w2'));
      await Future<void>.delayed(Duration.zero);

      expect(order, equals(<String>['w1-start'])); // w2 blocked

      gate.complete();
      await Future.wait(<Future<void>>[w1, w2]);
      expect(order, equals(<String>['w1-start', 'w1-end', 'w2']));
    });

    test('writer-preference: a queued writer runs before a later reader', () async {
      final ReadWriteLock lock = ReadWriteLock(); // writerPreferred: true
      final List<String> order = <String>[];
      final Completer<void> gate = Completer<void>();

      final Future<void> r1 = lock.read(() async {
        order.add('r1');
        await gate.future;
      });
      await Future<void>.delayed(Duration.zero);

      final Future<void> w = lock.write(() async => order.add('w'));
      final Future<void> r2 = lock.read(() async => order.add('r2'));
      await Future<void>.delayed(Duration.zero);

      gate.complete();
      await Future.wait(<Future<void>>[r1, w, r2]);
      expect(order, equals(<String>['r1', 'w', 'r2']));
    });

    test('reader-preference: queued readers drain before a waiting writer', () async {
      final ReadWriteLock lock = ReadWriteLock(writerPreferred: false);
      final List<String> order = <String>[];
      final Completer<void> gate = Completer<void>();

      final Future<void> r1 = lock.read(() async {
        order.add('r1');
        await gate.future;
      });
      await Future<void>.delayed(Duration.zero);

      final Future<void> w = lock.write(() async => order.add('w'));
      final Future<void> r2 = lock.read(() async => order.add('r2'));
      await Future<void>.delayed(Duration.zero);

      gate.complete();
      await Future.wait(<Future<void>>[r1, w, r2]);
      // r2 (a reader) jumps ahead of the queued writer.
      expect(order, equals(<String>['r1', 'r2', 'w']));
    });

    test('should return the action result and release on throw', () async {
      final ReadWriteLock lock = ReadWriteLock();

      expect(await lock.read(() async => 5), equals(5));
      expect(await lock.write(() async => 9), equals(9));

      await expectLater(lock.write<void>(() async => throw StateError('x')), throwsStateError);
      // Lock is free again after the throwing write.
      expect(lock.isWriteLocked, isFalse);
      expect(await lock.read(() async => 'ok'), equals('ok'));
    });
  });
}
