import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/iterable/iterable_indexed_extensions.dart';

void main() {
  group('mapIndexed', () {
    test('maps each element with its index', () {
      expect(
        <String>['a', 'b', 'c'].mapIndexed((int i, String e) => '$i:$e').toList(),
        <String>['0:a', '1:b', '2:c'],
      );
    });

    test('index starts at 0 and increments', () {
      expect(
        <int>[10, 20, 30].mapIndexed((int i, int e) => i + e).toList(),
        <int>[10, 21, 32],
      );
    });

    test('empty iterable yields empty', () {
      expect(<int>[].mapIndexed((int i, int e) => i).toList(), <int>[]);
    });

    test('single element gets index 0', () {
      expect(<String>['x'].mapIndexed((int i, String e) => (i, e)).toList(), <(int, String)>[
        (0, 'x'),
      ]);
    });
  });

  group('foldIndexed', () {
    test('folds with running index', () {
      // Sum of (index * element)
      final int result = <int>[1, 2, 3].foldIndexed<int>(
        0,
        (int acc, int i, int e) => acc + i * e,
      );
      // 0*1 + 1*2 + 2*3 = 0 + 2 + 6 = 8
      expect(result, 8);
    });

    test('returns initial value for empty iterable', () {
      expect(<int>[].foldIndexed<int>(42, (int acc, int i, int e) => acc + e), 42);
    });

    test('builds an index-tagged list', () {
      final List<String> result = <String>['a', 'b'].foldIndexed<List<String>>(
        <String>[],
        (List<String> acc, int i, String e) => <String>[...acc, '$i$e'],
      );
      expect(result, <String>['0a', '1b']);
    });

    test('single element folds once at index 0', () {
      expect(
        <int>[7].foldIndexed<int>(100, (int acc, int i, int e) => acc + i + e),
        107,
      );
    });
  });
}
