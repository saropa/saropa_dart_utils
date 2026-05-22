import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/batch_async_utils.dart';

void main() {
  group('mapBatched', () {
    test('maps every item preserving order', () async {
      final List<int> out = await mapBatched<int, int>(
        <int>[1, 2, 3, 4, 5],
        (int x) async => x * 10,
      );
      expect(out, <int>[10, 20, 30, 40, 50]);
    });

    test('processes items in batches of [batchSize]', () async {
      final List<int> concurrentNow = <int>[];
      int active = 0;
      int maxActive = 0;

      await mapBatched<int, int>(
        List<int>.generate(6, (int i) => i),
        (int x) async {
          active++;
          if (active > maxActive) maxActive = active;
          concurrentNow.add(active);
          await Future<void>.delayed(const Duration(milliseconds: 5));
          active--;
          return x;
        },
        batchSize: 2,
      );

      // Never more than batchSize items in flight at once.
      expect(maxActive, 2);
    });

    test('returns an empty list for empty input', () async {
      expect(await mapBatched<int, int>(<int>[], (int x) async => x), isEmpty);
    });

    test('handles a final partial batch smaller than batchSize', () async {
      final List<String> out = await mapBatched<int, String>(
        <int>[1, 2, 3, 4, 5],
        (int x) async => 'v$x',
        batchSize: 2,
      );
      expect(out, <String>['v1', 'v2', 'v3', 'v4', 'v5']);
    });
  });
}
