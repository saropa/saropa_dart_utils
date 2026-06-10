import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/iterable/iterable_sum_by_extensions.dart';

void main() {
  group('sumBy', () {
    test('sums the selector over all elements', () {
      expect(<String>['a', 'bb', 'ccc'].sumBy((String s) => s.length), 6);
    });

    test('returns 0 for an empty iterable', () {
      expect(<String>[].sumBy((String s) => s.length), 0);
    });

    test('supports double selectors', () {
      expect(<int>[1, 2].sumBy((int n) => n * 0.5), 1.5);
    });

    test('handles negative contributions', () {
      expect(<int>[5, -3, -2].sumBy((int n) => n), 0);
    });
  });

  group('averageBy', () {
    test('returns the mean of the selector', () {
      expect(<int>[1, 2, 4].averageBy((int n) => n), closeTo(2.3333, 0.0001));
    });

    test('returns null for an empty iterable', () {
      expect(<int>[].averageBy((int n) => n), isNull);
    });

    test('single element returns its value', () {
      expect(<int>[7].averageBy((int n) => n), 7.0);
    });

    test('always returns a double, even for integer inputs', () {
      expect(<int>[2, 4].averageBy((int n) => n), 3.0);
    });
  });
}
