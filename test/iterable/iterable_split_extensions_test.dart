import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/iterable/iterable_split_extensions.dart';

void main() {
  group('splitAt', () {
    test('splits into [0..index) and [index..end)', () {
      final (List<int>, List<int>) result = <int>[1, 2, 3, 4].splitAt(2);
      expect(result.$1, <int>[1, 2]);
      expect(result.$2, <int>[3, 4]);
    });

    test('index <= 0 puts everything in the second list', () {
      final (List<int>, List<int>) result = <int>[1, 2, 3].splitAt(0);
      expect(result.$1, <int>[]);
      expect(result.$2, <int>[1, 2, 3]);
    });

    test('negative index behaves like 0', () {
      final (List<int>, List<int>) result = <int>[1, 2].splitAt(-5);
      expect(result.$1, <int>[]);
      expect(result.$2, <int>[1, 2]);
    });

    test('index >= length puts everything in the first list', () {
      final (List<int>, List<int>) result = <int>[1, 2, 3].splitAt(10);
      expect(result.$1, <int>[1, 2, 3]);
      expect(result.$2, <int>[]);
    });

    test('index at length puts everything in the first list', () {
      final (List<int>, List<int>) result = <int>[1, 2].splitAt(2);
      expect(result.$1, <int>[1, 2]);
      expect(result.$2, <int>[]);
    });

    test('empty iterable yields two empty lists', () {
      final (List<int>, List<int>) result = <int>[].splitAt(1);
      expect(result.$1, <int>[]);
      expect(result.$2, <int>[]);
    });
  });

  group('splitAtFirstWhere', () {
    test('matching element goes into the second list', () {
      final (List<int>, List<int>) result =
          <int>[1, 2, 3, 4].splitAtFirstWhere((int x) => x == 3);
      expect(result.$1, <int>[1, 2]);
      expect(result.$2, <int>[3, 4]);
    });

    test('splits at FIRST match only', () {
      final (List<int>, List<int>) result =
          <int>[1, 5, 2, 5].splitAtFirstWhere((int x) => x == 5);
      expect(result.$1, <int>[1]);
      expect(result.$2, <int>[5, 2, 5]);
    });

    test('no match puts everything in the first list', () {
      final (List<int>, List<int>) result =
          <int>[1, 2, 3].splitAtFirstWhere((int x) => x > 10);
      expect(result.$1, <int>[1, 2, 3]);
      expect(result.$2, <int>[]);
    });

    test('match at first element yields empty first list', () {
      final (List<int>, List<int>) result =
          <int>[7, 8].splitAtFirstWhere((int x) => x == 7);
      expect(result.$1, <int>[]);
      expect(result.$2, <int>[7, 8]);
    });

    test('empty iterable yields two empty lists', () {
      final (List<int>, List<int>) result = <int>[].splitAtFirstWhere((int x) => true);
      expect(result.$1, <int>[]);
      expect(result.$2, <int>[]);
    });
  });
}
