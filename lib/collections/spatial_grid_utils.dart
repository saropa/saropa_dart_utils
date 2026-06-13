/// Uniform spatial grid index for 2D points — roadmap #506.
///
/// Buckets points into fixed-size square cells so that "everything near (x, y)"
/// can be answered by scanning only the handful of cells overlapping the query
/// region, instead of testing every stored point. This is the lightweight
/// alternative to a quadtree: it has no rebalancing, costs `O(1)` per insert,
/// and a radius query touches `O((2r / cellSize)^2)` cells. It is ideal when
/// points are roughly evenly spread; very clumped data degrades toward a linear
/// scan within the hot cells.
///
/// The cell size is the central tuning knob: too small wastes memory on empty
/// cells, too large makes each cell a mini linear scan. A good default is the
/// typical query radius.
library;

class _Entry<T> {
  const _Entry(this.item, this.x, this.y);
  final T item;
  final double x;
  final double y;
}

/// A grid index mapping 2D points to payloads of type [T].
class SpatialGrid<T> {
  /// Creates a grid whose square cells are [cellSize] units on a side.
  /// Requires `cellSize > 0`.
  /// Audited: 2026-06-12 11:26 EDT
  SpatialGrid(double cellSize) : _cellSize = _validatedCellSize(cellSize);

  // Validate via a static helper in the initializer (not a constructor body) so
  // the check survives release builds without an assert. The throw runs during
  // field init, before any resource is acquired, so no partially-constructed
  // object can leak and the avoid_exception_in_constructor lint stays satisfied.
  // `_cell` divides by `_cellSize`, so a zero/negative size would yield
  // Infinity/NaN cell coordinates and silently corrupt the grid.
  static double _validatedCellSize(double cellSize) {
    if (cellSize <= 0) {
      throw ArgumentError.value(cellSize, 'cellSize', 'must be > 0');
    }
    return cellSize;
  }

  final double _cellSize;
  // Keyed by (cellX, cellY); records use value equality so they work as keys.
  final Map<(int, int), List<_Entry<T>>> _cells = <(int, int), List<_Entry<T>>>{};
  int _size = 0;

  /// Total number of points stored.
  /// Audited: 2026-06-12 11:26 EDT
  int get length => _size;

  int _cell(double v) => (v / _cellSize).floor();

  /// Inserts [item] at position ([x], [y]). The same item may be inserted at
  /// multiple positions; each insertion is independent.
  ///
  /// Example:
  /// ```dart
  /// final SpatialGrid<String> g = SpatialGrid<String>(10)
  ///   ..insert('a', 1, 1)
  ///   ..insert('b', 5, 5);
  /// g.queryRadius(0, 0, 3); // ['a']
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  void insert(T item, double x, double y) {
    final (int, int) key = (_cell(x), _cell(y));
    _cells.putIfAbsent(key, () => <_Entry<T>>[]).add(_Entry<T>(item, x, y));
    _size++;
  }

  /// Items whose stored position lies within Euclidean distance [radius] of
  /// ([x], [y]). Requires `radius >= 0`. Order is unspecified.
  /// Audited: 2026-06-12 11:26 EDT
  List<T> queryRadius(double x, double y, double radius) {
    // Enforced in release: a negative radius would silently match points within
    // |radius| (r2 squares away the sign) instead of being rejected.
    if (radius < 0) {
      throw ArgumentError.value(radius, 'radius', 'must be >= 0');
    }
    final double r2 = radius * radius;
    // Filter the cell candidates by true distance — a cell overlapping the
    // query box can still hold points outside the circle.
    return <T>[
      for (final _Entry<T> e in _candidates(x, y, radius))
        if ((e.x - x) * (e.x - x) + (e.y - y) * (e.y - y) <= r2) e.item,
    ];
  }

  // All entries in cells overlapping the axis-aligned box around the circle.
  List<_Entry<T>> _candidates(double x, double y, double radius) {
    final int minX = _cell(x - radius);
    final int maxX = _cell(x + radius);
    final int minY = _cell(y - radius);
    final int maxY = _cell(y + radius);
    final List<_Entry<T>> out = <_Entry<T>>[];
    for (int cx = minX; cx <= maxX; cx++) {
      for (int cy = minY; cy <= maxY; cy++) {
        // ignore: saropa_lints/prefer_spread_over_addall -- accumulates across cells into a reused buffer
        out.addAll(_cells[(cx, cy)] ?? const <Never>[]);
      }
    }
    return out;
  }

  @override
  String toString() => 'SpatialGrid(length: $_size, cellSize: $_cellSize)';
}
