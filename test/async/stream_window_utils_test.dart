import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/stream_window_utils.dart';

void main() {
  group('windowCount', () {
    test('emits windows of exactly [count] elements', () async {
      final Stream<int> src = Stream<int>.fromIterable(<int>[1, 2, 3, 4, 5, 6]);
      final List<List<int>> out = await windowCount<int>(src, 3).toList();
      expect(out, <List<int>>[<int>[1, 2, 3], <int>[4, 5, 6]]);
    });

    test('flushes a trailing partial window on done', () async {
      final Stream<int> src = Stream<int>.fromIterable(<int>[1, 2, 3, 4]);
      final List<List<int>> out = await windowCount<int>(src, 3).toList();
      expect(out, <List<int>>[<int>[1, 2, 3], <int>[4]]);
    });

    test('emits nothing for an empty source', () async {
      final List<List<int>> out = await windowCount<int>(const Stream<int>.empty(), 2).toList();
      expect(out, isEmpty);
    });

    test('forwards source errors', () async {
      final Stream<int> src = Stream<int>.error(StateError('bad'));
      await expectLater(windowCount<int>(src, 2).toList(), throwsA(isA<StateError>()));
    });
  });
}
