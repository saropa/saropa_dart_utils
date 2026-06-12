/// Line simplification (Douglas–Peucker) — roadmap #547.
library;

import 'dart:math' show pow, sqrt;

/// Point for polyline.
class LineSimplifyUtils {
  /// Creates a 2D point at coordinates ([x], [y]).
  /// Audited: 2026-06-12 11:26 EDT
  const LineSimplifyUtils(double x, double y) : _x = x, _y = y;
  final double _x;

  /// X coordinate.
  /// Audited: 2026-06-12 11:26 EDT
  double get x => _x;
  final double _y;

  /// Y coordinate.
  /// Audited: 2026-06-12 11:26 EDT
  double get y => _y;

  @override
  String toString() => 'Point2(x: $_x, y: $_y)';
}

/// Douglas–Peucker line simplification: returns indices of [points] to keep within [epsilon] tolerance.
/// Audited: 2026-06-12 11:26 EDT
List<int> douglasPeuckerIndices(List<LineSimplifyUtils> points, double epsilon) {
  if (points.length < 3) return List.generate(points.length, (int i) => i);
  return _douglasPeucker(points, 0, points.length - 1, epsilon);
}

List<int> _douglasPeucker(List<LineSimplifyUtils> points, int start, int end, double epsilon) {
  // Base case: a segment with no interior points cannot be simplified further.
  if (end <= start + 1) return <int>[start, end];
  double maxDist = 0;
  int maxIdx = start;
  final LineSimplifyUtils a = points[start];
  final LineSimplifyUtils b = points[end];
  // Find the interior point farthest from the chord start->end; it is the only
  // candidate that could exceed tolerance, so it alone decides keep vs. discard.
  for (int i = start + 1; i < end; i++) {
    final double d = _perpendicularDistance(points[i], a, b);
    if (d > maxDist) {
      maxDist = d;
      maxIdx = i;
    }
  }
  // Whole span is within tolerance: drop every interior point, keep the endpoints.
  if (maxDist <= epsilon) return <int>[start, end];
  // The farthest point must be kept; recurse on each half split at it.
  final List<int> left = _douglasPeucker(points, start, maxIdx, epsilon);
  final List<int> right = _douglasPeucker(points, maxIdx, end, epsilon);
  // maxIdx is the last element of `left` and the first of `right`; drop the
  // trailing copy from `left` so the shared pivot is not duplicated on merge.
  return <int>[...left.sublist(0, left.length - 1), ...right];
}

double _perpendicularDistance(LineSimplifyUtils p, LineSimplifyUtils a, LineSimplifyUtils b) {
  final double deltaX = b._x - a._x;
  final double deltaY = b._y - a._y;
  final double n = pow(deltaX, 2).toDouble() + pow(deltaY, 2).toDouble();
  final double px = p._x - a._x;
  final double py = p._y - a._y;
  // Degenerate chord (a == b): distance is just the Euclidean |p - a|.
  if (n == 0) return sqrt(px * px + py * py);
  // Perpendicular distance = |cross(p-a, b-a)| / |b-a|. |b-a| is sqrt(n), NOT n:
  // dividing by n (the squared length) yields distance/length, not a distance,
  // so the epsilon tolerance would not be in real coordinate units.
  return (px * deltaY - py * deltaX).abs() / sqrt(n);
}
