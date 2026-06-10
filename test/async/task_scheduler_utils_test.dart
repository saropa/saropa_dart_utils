import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/task_scheduler_utils.dart';

void main() {
  group('TaskScheduler', () {
    test('should run at most `concurrency` tasks at once', () async {
      final TaskScheduler scheduler = TaskScheduler(concurrency: 2);
      final Completer<void> gate = Completer<void>();

      final List<Future<void>> futures = <Future<void>>[
        for (int i = 0; i < 4; i++) scheduler.schedule(() => gate.future),
      ];

      // The cap is enforced synchronously: 2 in flight, 2 waiting.
      expect(scheduler.running, equals(2));
      expect(scheduler.pending, equals(2));

      gate.complete();
      await Future.wait(futures);

      expect(scheduler.running, equals(0));
      expect(scheduler.pending, equals(0));
    });

    test('should dispatch the highest-priority waiter first', () async {
      final TaskScheduler scheduler = TaskScheduler(concurrency: 1);
      final List<String> order = <String>[];
      final Completer<void> gate = Completer<void>();

      // 'A' occupies the single slot and parks on the gate; B/C/D queue behind.
      final Future<void> a = scheduler.schedule(() async {
        order.add('A');
        await gate.future;
      });
      final Future<void> b = scheduler.schedule(() async => order.add('B'), priority: 1);
      final Future<void> c = scheduler.schedule(() async => order.add('C'), priority: 5);
      final Future<void> d = scheduler.schedule(() async => order.add('D'), priority: 3);

      gate.complete();
      await Future.wait(<Future<void>>[a, b, c, d]);

      expect(order, equals(<String>['A', 'C', 'D', 'B']));
    });

    test('should preserve submission order among equal priorities', () async {
      final TaskScheduler scheduler = TaskScheduler(concurrency: 1);
      final List<String> order = <String>[];
      final Completer<void> gate = Completer<void>();

      final Future<void> a = scheduler.schedule(() async {
        order.add('A');
        await gate.future;
      });
      final Future<void> x = scheduler.schedule(() async => order.add('X'), priority: 1);
      final Future<void> y = scheduler.schedule(() async => order.add('Y'), priority: 1);
      final Future<void> z = scheduler.schedule(() async => order.add('Z'), priority: 1);

      gate.complete();
      await Future.wait(<Future<void>>[a, x, y, z]);

      expect(order, equals(<String>['A', 'X', 'Y', 'Z']));
    });

    test('should return the task result', () async {
      final TaskScheduler scheduler = TaskScheduler(concurrency: 2);

      expect(await scheduler.schedule(() async => 7), equals(7));
    });

    test('should surface a task error without stalling the scheduler', () async {
      final TaskScheduler scheduler = TaskScheduler(concurrency: 1);

      final Future<int> bad = scheduler.schedule<int>(() async => throw StateError('boom'));
      final Future<int> good = scheduler.schedule<int>(() async => 42);

      await expectLater(bad, throwsStateError);
      expect(await good, equals(42));
      expect(scheduler.running, equals(0));
    });

    test('should reject a concurrency below 1', () {
      expect(() => TaskScheduler(concurrency: 0), throwsA(isA<AssertionError>()));
    });
  });
}
