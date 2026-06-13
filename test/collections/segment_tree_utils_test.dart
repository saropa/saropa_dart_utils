import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/segment_tree_utils.dart';

void main() {
  group('SegmentTree', () {
    group('sum', () {
      test('should sum an inclusive interior range', () {
        final SegmentTree t = SegmentTree.sum(<num>[1, 2, 3, 4, 5]);

        expect(t.query(1, 3), equals(9));
      });

      test('should sum the whole range', () {
        final SegmentTree t = SegmentTree.sum(<num>[1, 2, 3, 4, 5]);

        expect(t.query(0, 4), equals(15));
      });

      test('should reflect a point update', () {
        final SegmentTree t = SegmentTree.sum(<num>[1, 2, 3])..update(1, 10);

        expect(t.query(0, 2), equals(14));
        expect(t.valueAt(1), equals(10));
      });
    });

    group('min', () {
      test('should return the minimum over a range', () {
        final SegmentTree t = SegmentTree.min(<num>[3, 1, 4, 1, 5]);

        expect(t.query(0, 4), equals(1));
        expect(t.query(2, 4), equals(1));
        expect(t.query(2, 2), equals(4));
      });

      test('should track a lowered value after update', () {
        final SegmentTree t = SegmentTree.min(<num>[3, 4, 5])..update(2, -2);

        expect(t.query(0, 2), equals(-2));
      });
    });

    group('max', () {
      test('should return the maximum over a range', () {
        final SegmentTree t = SegmentTree.max(<num>[3, 1, 4, 1, 5]);

        expect(t.query(0, 2), equals(4));
        expect(t.query(3, 4), equals(5));
      });
    });

    group('bounds', () {
      test('should assert on an out-of-range update index', () {
        final SegmentTree t = SegmentTree.sum(<num>[1, 2]);

        expect(() => t.update(2, 1), throwsA(isA<RangeError>()));
      });

      test('should assert on an inverted range', () {
        final SegmentTree t = SegmentTree.sum(<num>[1, 2, 3]);

        expect(() => t.query(2, 1), throwsA(isA<RangeError>()));
      });
    });

    test('should match brute-force sum/min/max across updates on a larger list', () {
      final List<num> values = <num>[
        for (int i = 0; i < 50; i++) ((i * 11 + 5) % 23) - 11,
      ];
      final SegmentTree sum = SegmentTree.sum(List<num>.of(values));
      final SegmentTree min = SegmentTree.min(List<num>.of(values));
      final SegmentTree max = SegmentTree.max(List<num>.of(values));

      // Apply deterministic updates to all three trees and the oracle list.
      final List<List<int>> updates = <List<int>>[
        <int>[5, 100],
        <int>[0, -50],
        <int>[49, 7],
        <int>[20, 3],
      ];
      for (final List<int> u in updates) {
        values[u[0]] = u[1];
        sum.update(u[0], u[1]);
        min.update(u[0], u[1]);
        max.update(u[0], u[1]);
      }

      // Verify every (low, high) range against a direct scan of the oracle.
      for (int low = 0; low < values.length; low++) {
        for (int high = low; high < values.length; high++) {
          num s = 0;
          num mn = double.infinity;
          num mx = double.negativeInfinity;
          for (int i = low; i <= high; i++) {
            s += values[i];
            mn = math.min(mn, values[i]);
            mx = math.max(mx, values[i]);
          }
          expect(sum.query(low, high), equals(s), reason: 'sum [$low,$high]');
          expect(min.query(low, high), equals(mn), reason: 'min [$low,$high]');
          expect(max.query(low, high), equals(mx), reason: 'max [$low,$high]');
        }
      }
    });
  });
}
