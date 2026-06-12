import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/spatial_grid_utils.dart';

void main() {
  group('SpatialGrid', () {
    test('should return points within the radius and exclude those outside', () {
      final SpatialGrid<String> g = SpatialGrid<String>(10)
        ..insert('near', 1, 1)
        ..insert('far', 50, 50);

      expect(g.queryRadius(0, 0, 3), equals(<String>['near']));
    });

    test('should exclude a point inside the candidate cells but outside the circle', () {
      // (7, 7) shares the query's cell band but its Euclidean distance from the
      // origin (~9.9) exceeds the radius of 5, so it must be filtered out.
      final SpatialGrid<String> g = SpatialGrid<String>(10)..insert('corner', 7, 7);

      expect(g.queryRadius(0, 0, 5), isEmpty);
    });

    test('should find points spanning multiple cells', () {
      // From (5,5) with radius 5: (4,4) and (6,6) are ~1.41 away (in); (0,0) is
      // ~7.07 and (9,9) is ~5.66 away (both out, despite sharing nearby cells).
      final SpatialGrid<int> g = SpatialGrid<int>(5)
        ..insert(1, 0, 0)
        ..insert(2, 4, 4)
        ..insert(3, 6, 6)
        ..insert(4, 9, 9);

      final List<int> hits = g.queryRadius(5, 5, 5)..sort();

      expect(hits, equals(<int>[2, 3]));
    });

    test('should track length across inserts', () {
      final SpatialGrid<int> g = SpatialGrid<int>(1)
        ..insert(1, 0, 0)
        ..insert(2, 0, 0);

      expect(g.length, equals(2));
    });

    test('should handle negative coordinates', () {
      final SpatialGrid<String> g = SpatialGrid<String>(4)
        ..insert('a', -3, -3)
        ..insert('b', -1, -1);

      final List<String> hits = g.queryRadius(-2, -2, 2)..sort();

      expect(hits, equals(<String>['a', 'b']));
    });

    test('should assert on a non-positive cell size', () {
      expect(() => SpatialGrid<int>(0), throwsA(isA<AssertionError>()));
    });

    test('should assert on a negative radius', () {
      final SpatialGrid<int> g = SpatialGrid<int>(1)..insert(1, 0, 0);

      expect(() => g.queryRadius(0, 0, -1), throwsA(isA<AssertionError>()));
    });

    test('should match a brute-force scan over a deterministic point cloud', () {
      final SpatialGrid<int> g = SpatialGrid<int>(8);
      final List<(double, double)> pts = <(double, double)>[
        for (int i = 0; i < 60; i++)
          (((i * 13) % 40).toDouble() - 20, ((i * 7) % 40).toDouble() - 20),
      ];
      for (int i = 0; i < pts.length; i++) {
        g.insert(i, pts[i].$1, pts[i].$2);
      }

      // For several query centers and radii, the grid result must equal the set
      // of indices a direct distance scan would return.
      for (final (double, double) center in <(double, double)>[(0, 0), (10, -5), (-15, 12)]) {
        for (final double r in <double>[3, 9, 25]) {
          final List<int> brute = <int>[
            for (int i = 0; i < pts.length; i++)
              if (_dist(pts[i], center) <= r) i,
          ]..sort();
          final List<int> got = g.queryRadius(center.$1, center.$2, r)..sort();
          expect(got, equals(brute), reason: 'center=$center r=$r');
        }
      }
    });
  });
}

double _dist((double, double) a, (double, double) b) =>
    math.sqrt((a.$1 - b.$1) * (a.$1 - b.$1) + (a.$2 - b.$2) * (a.$2 - b.$2));
