import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/fenwick_tree_utils.dart';

void main() {
  group('FenwickTree', () {
    // Brute-force oracle: inclusive prefix sum of a plain list.
    num bruteForcePrefix(List<num> values, int index) {
      num sum = 0;
      for (int i = 0; i <= index; i++) {
        sum += values[i];
      }
      return sum;
    }

    group('constructor', () {
      test('should create a tree of all zeros for a given size', () {
        final FenwickTree t = FenwickTree(4);

        expect(t.length, equals(4));
        expect(t.prefixSum(3), equals(0));
        expect(t.valueAt(2), equals(0));
      });

      test('should allow a size of zero', () {
        final FenwickTree t = FenwickTree(0);

        expect(t.length, equals(0));
      });
    });

    group('fromList', () {
      test('should seed prefix sums from the given values', () {
        final FenwickTree t = FenwickTree.fromList(<num>[1, 2, 3, 4]);

        expect(t.length, equals(4));
        expect(t.prefixSum(0), equals(1));
        expect(t.prefixSum(3), equals(10));
      });

      test('should handle a single element', () {
        final FenwickTree t = FenwickTree.fromList(<num>[7]);

        expect(t.prefixSum(0), equals(7));
        expect(t.valueAt(0), equals(7));
      });
    });

    group('update', () {
      test('should add a delta to a single element', () {
        final FenwickTree t = FenwickTree(5)..update(2, 10);

        expect(t.valueAt(2), equals(10));
        expect(t.prefixSum(4), equals(10));
      });

      test('should accumulate repeated updates to the same index', () {
        final FenwickTree t = FenwickTree(3)
          ..update(1, 5)
          ..update(1, -2);

        expect(t.valueAt(1), equals(3));
      });
    });

    group('rangeSum', () {
      final FenwickTree t = FenwickTree.fromList(<num>[1, 2, 3, 4, 5]);

      test('should sum an inclusive interior range', () {
        expect(t.rangeSum(1, 3), equals(9));
      });

      test('should sum a range starting at zero', () {
        expect(t.rangeSum(0, 2), equals(6));
      });

      test('should sum a single-element range', () {
        expect(t.rangeSum(4, 4), equals(5));
      });

      test('should sum the whole range', () {
        expect(t.rangeSum(0, 4), equals(15));
      });
    });

    group('bounds', () {
      test('should throw on an out-of-range update index', () {
        final FenwickTree t = FenwickTree(2);

        expect(() => t.update(2, 1), throwsA(isA<RangeError>()));
      });

      test('should throw on an inverted range', () {
        final FenwickTree t = FenwickTree(5);

        expect(() => t.rangeSum(3, 1), throwsA(isA<RangeError>()));
      });
    });

    test('should match a brute-force oracle across updates on a larger list', () {
      final List<num> values = <num>[
        for (int i = 0; i < 40; i++) ((i * 7 + 3) % 17) - 8,
      ];
      final FenwickTree t = FenwickTree.fromList(values);

      // Verify prefix sums match the oracle at every index.
      for (int i = 0; i < values.length; i++) {
        expect(t.prefixSum(i), equals(bruteForcePrefix(values, i)), reason: 'prefix $i');
      }

      // Apply a few deterministic point updates and re-verify everywhere.
      final List<List<int>> deltas = <List<int>>[
        <int>[5, 9],
        <int>[12, -4],
        <int>[39, 100],
        <int>[0, -3],
      ];
      for (final List<int> d in deltas) {
        t.update(d[0], d[1]);
        values[d[0]] += d[1];
      }
      for (int i = 0; i < values.length; i++) {
        expect(
          t.prefixSum(i),
          equals(bruteForcePrefix(values, i)),
          reason: 'after-update prefix $i',
        );
      }
    });
  });
}
