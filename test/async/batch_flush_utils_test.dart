import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/batch_flush_utils.dart';

void main() {
  group('BatchFlushUtils', () {
    test('auto-flushes when the buffer reaches batchSize', () {
      final List<List<int>> flushed = <List<int>>[];
      final BatchFlushUtils<int> batcher = BatchFlushUtils<int>(3, flushed.add);

      batcher.add(1);
      batcher.add(2);
      expect(flushed, isEmpty); // not yet at batchSize
      expect(batcher, hasLength(2));

      batcher.add(3);
      expect(flushed, <List<int>>[
        <int>[1, 2, 3],
      ]);
      expect(batcher, hasLength(0)); // buffer cleared after flush
    });

    test('manual flush emits and clears the partial buffer', () {
      final List<List<int>> flushed = <List<int>>[];
      final BatchFlushUtils<int> batcher = BatchFlushUtils<int>(10, flushed.add);

      batcher.add(1);
      batcher.add(2);
      batcher.flush();
      expect(flushed, <List<int>>[
        <int>[1, 2],
      ]);
      expect(batcher, hasLength(0));
    });

    test('flush on an empty buffer is a no-op', () {
      var calls = 0;
      final BatchFlushUtils<int> batcher = BatchFlushUtils<int>(5, (_) => calls++);
      batcher.flush();
      expect(calls, 0);
    });

    test('emitted batch is a copy decoupled from the internal buffer', () {
      final List<List<int>> flushed = <List<int>>[];
      final BatchFlushUtils<int> batcher = BatchFlushUtils<int>(2, flushed.add);
      batcher
        ..add(1)
        ..add(2); // flush -> [1, 2]
      batcher
        ..add(3)
        ..add(4); // flush -> [3, 4]
      // First batch must be unaffected by subsequent adds.
      expect(flushed, <List<int>>[
        <int>[1, 2],
        <int>[3, 4],
      ]);
    });

    test('toString reports batchSize and current length', () {
      final BatchFlushUtils<int> batcher = BatchFlushUtils<int>(5, (_) {});
      batcher.add(1);
      expect(batcher.toString(), 'BatchFlushUtils(batchSize: 5, length: 1)');
    });
  });
}
