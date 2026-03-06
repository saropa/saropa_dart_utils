/// Line simplification (Douglas–Peucker) — roadmap #547.
library;

import 'dart:math' show pow;

/// Point for polyline.
class LineSimplifyUtils {
  const LineSimplifyUtils(double x, double y) : _x = x, _y = y;
  final double _x;

  /// X coordinate.
  double get x => _x;
  final double _y;

  /// Y coordinate.
  double get y => _y;

  @override
  String toString() => 'Point2(x: $_x, y: $_y)';
}

/// Douglas–Peucker line simplification: returns indices of [points] to keep within [epsilon] tolerance.
List<int> douglasPeuckerIndices(List<LineSimplifyUtils> points, double epsilon) {
  if (points.length < 3) return List.generate(points.length, (int i) => i);
  return _douglasPeucker(points, 0, points.length - 1, epsilon);
}

List<int> _douglasPeucker(List<LineSimplifyUtils> points, int start, int end, double epsilon) {
  if (end <= start + 1) return <int>[start, end];
  double maxDist = 0;
  int maxIdx = start;
  final LineSimplifyUtils a = points[start];
  final LineSimplifyUtils b = points[end];
  for (int i = start + 1; i < end; i++) {
    final double d = _perpendicularDistance(points[i], a, b);
    if (d > maxDist) {
      maxDist = d;
      maxIdx = i;
    }
  }
  if (maxDist <= epsilon) return <int>[start, end];
  final List<int> left = _douglasPeucker(points, start, maxIdx, epsilon);
  final List<int> right = _douglasPeucker(points, maxIdx, end, epsilon);
  return <int>[...left.sublist(0, left.length - 1), ...right];
}

double _perpendicularDistance(LineSimplifyUtils p, LineSimplifyUtils a, LineSimplifyUtils b) {
  final double deltaX = b._x - a._x;
  final double deltaY = b._y - a._y;
  final double n = pow(deltaX, 2).toDouble() + pow(deltaY, 2).toDouble();
  final double px = p._x - a._x;
  final double py = p._y - a._y;
  if (n == 0) return px.abs() + py.abs();
  return (px * deltaY - py * deltaX).abs() / n;
}
