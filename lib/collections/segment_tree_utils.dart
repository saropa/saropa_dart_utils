/// Segment tree for associative range queries (sum / min / max) — roadmap #495.
///
/// Answers range queries (sum, minimum, or maximum over an inclusive index
/// range) in `O(log n)` with `O(log n)` point updates. A plain array makes one
/// of the two cheap and the other `O(n)`; the segment tree balances both by
/// storing each internal node's combined value over a contiguous span.
///
/// This is an *iterative* (bottom-up) segment tree: the leaves live in
/// `_tree[n .. 2n)` and each internal node `i` holds `combine(_tree[2i],
/// _tree[2i+1])`. The combine operation must be associative and commutative —
/// sum, min, and max all are — because the iterative range walk may merge the
/// left and right partial results in either order.
library;

import 'dart:math' as math;

/// Combines two values into one (must be associative and commutative).
typedef SegmentCombine = num Function(num a, num b);

/// A segment tree over `num` supporting point updates and range queries.
class SegmentTree {
  /// Builds a sum tree: range queries return the sum over the range.
  SegmentTree.sum(List<num> values) : this._(values, _add, 0);

  /// Builds a min tree: range queries return the minimum over the range.
  /// The identity is `double.infinity` so an empty merge never lowers a result.
  SegmentTree.min(List<num> values) : this._(values, math.min, double.infinity);

  /// Builds a max tree: range queries return the maximum over the range.
  /// The identity is `double.negativeInfinity` for the symmetric reason.
  SegmentTree.max(List<num> values) : this._(values, math.max, double.negativeInfinity);

  SegmentTree._(List<num> values, this._combine, this._identity)
    : _n = values.length,
      _tree = List<num>.filled(values.length * 2, _identity) {
    // Place the raw values in the leaf half, then fold pairs up to the root.
    for (int i = 0; i < _n; i++) {
      _tree[_n + i] = values[i];
    }
    for (int i = _n - 1; i >= 1; i--) {
      _tree[i] = _combine(_tree[i * 2], _tree[i * 2 + 1]);
    }
  }

  final int _n;
  final List<num> _tree;
  final SegmentCombine _combine;
  final num _identity;

  static num _add(num a, num b) => a + b;

  /// Number of elements in the tree.
  int get length => _n;

  /// Sets the element at [index] (0-based) to [value], in `O(log n)`.
  /// Requires `0 <= index < length`.
  ///
  /// Example:
  /// ```dart
  /// final SegmentTree t = SegmentTree.sum(<num>[1, 2, 3]);
  /// t.update(1, 10);
  /// t.query(0, 2); // 14
  /// ```
  void update(int index, num value) {
    assert(index >= 0 && index < _n, 'index ($index) out of range [0, $_n)');
    int pos = index + _n;
    _tree[pos] = value;
    // Recompute every ancestor by re-combining its two children.
    for (pos >>= 1; pos >= 1; pos >>= 1) {
      _tree[pos] = _combine(_tree[pos * 2], _tree[pos * 2 + 1]);
    }
  }

  /// Combined value over the inclusive range `[low..high]`, in `O(log n)`.
  /// Requires `0 <= low <= high < length`.
  ///
  /// Example:
  /// ```dart
  /// final SegmentTree t = SegmentTree.max(<num>[3, 1, 4, 1, 5]);
  /// t.query(1, 3); // 4
  /// ```
  num query(int low, int high) {
    assert(low >= 0 && low <= high, 'low ($low) must be in 0..high ($high)');
    assert(high < _n, 'high ($high) out of range [0, $_n)');
    num result = _identity;
    // Walk both boundaries inward, folding in any node that sits fully inside
    // the range (signaled by the boundary index being odd / even respectively).
    int l = low + _n;
    int r = high + _n + 1;
    while (l < r) {
      if (l & 1 == 1) result = _combine(result, _tree[l++]);
      if (r & 1 == 1) result = _combine(result, _tree[--r]);
      l >>= 1;
      r >>= 1;
    }
    return result;
  }

  /// The current value at [index] (0-based).
  /// Requires `0 <= index < length`.
  num valueAt(int index) {
    assert(index >= 0 && index < _n, 'index ($index) out of range [0, $_n)');
    return _tree[index + _n];
  }

  @override
  String toString() => 'SegmentTree(length: $_n)';
}
