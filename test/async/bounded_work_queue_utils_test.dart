import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/bounded_work_queue_utils.dart';

void main() {
  group('BoundedWorkQueue', () {
    test('should reject a maxSize below 1', () {
      expect(() => BoundedWorkQueue<int>(maxSize: 0), throwsA(isA<AssertionError>()));
    });

    test('should buffer up to maxSize without blocking', () async {
      final BoundedWorkQueue<int> queue = BoundedWorkQueue<int>(maxSize: 2);

      await queue.push(1);
      await queue.push(2);

      expect(queue.length, equals(2));
      expect(queue.isFull, isTrue);
    });

    test('should FIFO-order pulled items', () async {
      final BoundedWorkQueue<int> queue = BoundedWorkQueue<int>(maxSize: 3);
      await queue.push(1);
      await queue.push(2);
      await queue.push(3);

      expect(await queue.pull(), equals(1));
      expect(await queue.pull(), equals(2));
      expect(await queue.pull(), equals(3));
    });

    test('should hand a pushed item directly to a waiting consumer', () async {
      final BoundedWorkQueue<int> queue = BoundedWorkQueue<int>(maxSize: 1);

      final Future<int> pending = queue.pull(); // blocks: buffer empty
      expect(queue.pendingConsumers, equals(1));

      await queue.push(42);
      expect(await pending, equals(42));
      expect(queue.length, equals(0)); // never touched the buffer
    });

    test('should apply backpressure when full and release on pull', () async {
      final BoundedWorkQueue<int> queue = BoundedWorkQueue<int>(maxSize: 1);
      await queue.push(1); // buffer full

      bool pushed = false;
      final Future<void> blocked = queue.push(2).then((_) => pushed = true);
      await Future<void>.delayed(Duration.zero);

      // Second push is parked behind the full buffer.
      expect(pushed, isFalse);
      expect(queue.pendingProducers, equals(1));

      expect(await queue.pull(), equals(1)); // frees a slot
      await blocked;
      expect(pushed, isTrue);
      expect(await queue.pull(), equals(2)); // the admitted item
    });

    group('tryPush / tryPull', () {
      test('tryPush should return false when full instead of blocking', () async {
        final BoundedWorkQueue<int> queue = BoundedWorkQueue<int>(maxSize: 1);

        expect(queue.tryPush(1), isTrue);
        expect(queue.tryPush(2), isFalse);
      });

      test('tryPull should return null when empty', () {
        final BoundedWorkQueue<int> queue = BoundedWorkQueue<int>(maxSize: 1);

        expect(queue.tryPull(), isNull);
      });
    });

    group('close', () {
      test('should reject a push after close', () async {
        final BoundedWorkQueue<int> queue = BoundedWorkQueue<int>(maxSize: 1);
        queue.close();

        await expectLater(queue.push(1), throwsStateError);
        expect(() => queue.tryPush(1), throwsStateError);
      });

      test('should still drain buffered items after close, then error', () async {
        final BoundedWorkQueue<int> queue = BoundedWorkQueue<int>(maxSize: 2);
        await queue.push(1);
        await queue.push(2);
        queue.close();

        expect(await queue.pull(), equals(1));
        expect(await queue.pull(), equals(2));
        await expectLater(queue.pull(), throwsStateError); // closed and empty
      });

      test('should fail blocked producers and consumers on close', () async {
        final BoundedWorkQueue<int> queue = BoundedWorkQueue<int>(maxSize: 1);
        await queue.push(1);
        final Future<void> blockedProducer = queue.push(2);

        final BoundedWorkQueue<int> empty = BoundedWorkQueue<int>(maxSize: 1);
        final Future<int> blockedConsumer = empty.pull();

        queue.close();
        empty.close();

        await expectLater(blockedProducer, throwsStateError);
        await expectLater(blockedConsumer, throwsStateError);
      });
    });
  });
}
