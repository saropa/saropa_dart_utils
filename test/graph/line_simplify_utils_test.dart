import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/graph/line_simplify_utils.dart';

void main() {
  group('LineSimplifyUtils (point)', () {
    test('constructor exposes x and y', () {
      const LineSimplifyUtils p = LineSimplifyUtils(1.5, -2.5);
      expect(p.x, 1.5);
      expect(p.y, -2.5);
    });

    test('toString renders coordinates', () {
      expect(const LineSimplifyUtils(3, 4).toString(), 'Point2(x: 3.0, y: 4.0)');
    });
  });

  group('douglasPeuckerIndices', () {
    test('empty input returns empty', () {
      expect(douglasPeuckerIndices(<LineSimplifyUtils>[], 1), <int>[]);
    });

    test('single point returns its index', () {
      expect(
        douglasPeuckerIndices(<LineSimplifyUtils>[const LineSimplifyUtils(0, 0)], 1),
        <int>[0],
      );
    });

    test('two points return both indices unchanged', () {
      expect(
        douglasPeuckerIndices(<LineSimplifyUtils>[
          const LineSimplifyUtils(0, 0),
          const LineSimplifyUtils(5, 5),
        ], 1),
        <int>[0, 1],
      );
    });

    test('collinear points within tolerance keep only endpoints', () {
      // Straight line on the x-axis: the middle point is 0 distance from the chord.
      final List<LineSimplifyUtils> points = <LineSimplifyUtils>[
        const LineSimplifyUtils(0, 0),
        const LineSimplifyUtils(5, 0),
        const LineSimplifyUtils(10, 0),
      ];
      expect(douglasPeuckerIndices(points, 1), <int>[0, 2]);
    });

    test('keeps a sharp middle point that exceeds tolerance', () {
      // Middle point spikes far off the chord -> must be retained.
      final List<LineSimplifyUtils> points = <LineSimplifyUtils>[
        const LineSimplifyUtils(0, 0),
        const LineSimplifyUtils(5, 100),
        const LineSimplifyUtils(10, 0),
      ];
      expect(douglasPeuckerIndices(points, 1), <int>[0, 1, 2]);
    });

    test('large epsilon discards interior points of a gentle curve', () {
      // A small bump well under a large tolerance collapses to endpoints.
      final List<LineSimplifyUtils> points = <LineSimplifyUtils>[
        const LineSimplifyUtils(0, 0),
        const LineSimplifyUtils(1, 0.1),
        const LineSimplifyUtils(2, 0.2),
        const LineSimplifyUtils(3, 0),
      ];
      expect(douglasPeuckerIndices(points, 100), <int>[0, 3]);
    });

    test('keeps interior points when epsilon is small', () {
      // Same curve, tiny tolerance: the off-line points must survive.
      final List<LineSimplifyUtils> points = <LineSimplifyUtils>[
        const LineSimplifyUtils(0, 0),
        const LineSimplifyUtils(5, 5),
        const LineSimplifyUtils(10, 0),
      ];
      expect(douglasPeuckerIndices(points, 0.001), <int>[0, 1, 2]);
    });

    test('tolerance is a true perpendicular distance, not distance/length', () {
      // Chord (0,0)->(10,0) has length 10. The middle point (5,5) sits exactly
      // 5 units off the chord. With epsilon 2 it MUST be kept (5 > 2). The old
      // buggy formula divided by the squared length (100), giving 0.5 < 2, which
      // would wrongly drop it -> this test pins the corrected distance.
      final List<LineSimplifyUtils> points = <LineSimplifyUtils>[
        const LineSimplifyUtils(0, 0),
        const LineSimplifyUtils(5, 5),
        const LineSimplifyUtils(10, 0),
      ];
      expect(douglasPeuckerIndices(points, 2), <int>[0, 1, 2]);
    });
  });
}
