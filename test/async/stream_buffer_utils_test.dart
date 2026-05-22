import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/stream_buffer_utils.dart';

void main() {
  group('bufferCount', () {
    test('emits lists of exactly [count] elements', () async {
      final Stream<int> src = Stream<int>.fromIterable(<int>[1, 2, 3, 4]);
      final List<List<int>> out = await bufferCount<int>(src, 2).toList();
      expect(out, <List<int>>[
        <int>[1, 2],
        <int>[3, 4],
      ]);
    });

    test('flushes a trailing partial buffer on done', () async {
      final Stream<int> src = Stream<int>.fromIterable(<int>[1, 2, 3, 4, 5]);
      final List<List<int>> out = await bufferCount<int>(src, 2).toList();
      expect(out, <List<int>>[
        <int>[1, 2],
        <int>[3, 4],
        <int>[5],
      ]);
    });

    test('emits nothing for an empty source', () async {
      final List<List<int>> out = await bufferCount<int>(const Stream<int>.empty(), 3).toList();
      expect(out, isEmpty);
    });

    test('forwards source errors', () async {
      final Stream<int> src = Stream<int>.error(StateError('bad'));
      await expectLater(bufferCount<int>(src, 2).toList(), throwsA(isA<StateError>()));
    });

    test('a count larger than the element total yields one final buffer', () async {
      final Stream<int> src = Stream<int>.fromIterable(<int>[1, 2]);
      final List<List<int>> out = await bufferCount<int>(src, 10).toList();
      expect(out, <List<int>>[
        <int>[1, 2],
      ]);
    });
  });
}
