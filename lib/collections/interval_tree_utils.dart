/// Interval tree for overlap (stabbing) queries — roadmap #494.
///
/// Answers "which intervals contain this point?" and "which intervals overlap
/// this range?" in `O(log n + k)` (k = matches) instead of the `O(n)` linear
/// scan a plain list needs. Distinct from `IntervalSchedulingUtils` (which picks
/// a maximum non-overlapping subset) and `weightedIntervals` (a DP optimizer):
/// this is the lookup index for spatial/temporal overlap — calendar conflicts,
/// IP-range matching, genomic ranges, gap detection.
///
/// Built once from a fixed set of intervals (the tree is balanced by median
/// split and not mutated afterward). Bounds are `num` and inclusive on both
/// ends, so `[10, 20]` contains both 10 and 20.
library;

import 'dart:math' as math;

import 'package:meta/meta.dart';

/// One inclusive interval `[low, high]` carrying a [value].
@immutable
class IntervalEntry<T> {
  /// Creates an interval `[low, high]` (inclusive) labeled with [value].
  /// Requires `low <= high`.
  IntervalEntry(this.low, this.high, this.value)
    : assert(low <= high, 'low ($low) must be <= high ($high)');

  /// Inclusive lower bound.
  final num low;

  /// Inclusive upper bound.
  final num high;

  /// The payload this interval carries (an event, range owner, etc.).
  final T value;

  /// Whether [point] lies within `[low, high]` (inclusive).
  bool contains(num point) => low <= point && point <= high;

  /// Whether this interval overlaps the inclusive range `[low, high]` given by
  /// [otherLow]/[otherHigh]. Two inclusive ranges overlap iff each starts at or
  /// before the other ends.
  bool overlaps(num otherLow, num otherHigh) => low <= otherHigh && high >= otherLow;

  @override
  bool operator ==(Object other) =>
      other is IntervalEntry<T> &&
      other.low == low &&
      other.high == high &&
      other.value == value;

  @override
  int get hashCode => Object.hash(low, high, value);

  @override
  String toString() => 'IntervalEntry($low, $high, $value)';
}

/// A balanced binary search tree of [IntervalEntry] keyed by `low`, augmented
/// with the maximum `high` in each subtree so overlap queries can prune whole
/// branches.
class _Node<T> {
  _Node(this.entry) : maxHigh = entry.high;

  final IntervalEntry<T> entry;
  _Node<T>? left;
  _Node<T>? right;

  /// Largest `high` in this node's subtree; the augmentation that lets a query
  /// skip a branch once its reach falls short of the query's lower bound.
  num maxHigh;
}

/// An immutable, balanced interval tree over a fixed set of [IntervalEntry]s.
class IntervalTree<T> {
  /// Builds a balanced tree from [entries] (any order). Construction is
  /// `O(n log n)` to sort; queries are then `O(log n + k)`.
  IntervalTree(Iterable<IntervalEntry<T>> entries) {
    final List<IntervalEntry<T>> sorted = entries.toList()
      ..sort((IntervalEntry<T> a, IntervalEntry<T> b) => a.low.compareTo(b.low));
    _size = sorted.length;
    _root = _build(sorted, 0, sorted.length - 1);
  }

  _Node<T>? _root;
  int _size = 0;

  /// Number of intervals in the tree.
  int get size => _size;

  /// Whether the tree holds no intervals.
  bool get isEmpty => _size == 0;

  /// All intervals that contain [point], in ascending `low` order.
  // ignore: no_equal_arguments -- a point stab is the degenerate range [point, point]
  List<IntervalEntry<T>> queryPoint(num point) => queryRange(point, point);

  /// All intervals overlapping the inclusive range `[low, high]`, in ascending
  /// `low` order. Requires `low <= high`.
  List<IntervalEntry<T>> queryRange(num low, num high) {
    assert(low <= high, 'low ($low) must be <= high ($high)');
    final List<IntervalEntry<T>> results = <IntervalEntry<T>>[];
    _collect(_root, low, high, results);
    return results;
  }

  /// Whether any interval overlaps `[low, high]`. Short-circuits on the first
  /// match, so it is cheaper than checking `queryRange(...).isNotEmpty`.
  bool hasOverlap(num low, num high) {
    assert(low <= high, 'low ($low) must be <= high ($high)');
    return _anyOverlap(_root, low, high);
  }

  /// Builds a balanced subtree from `sorted[lo..hi]`, picking the median as the
  /// root so the tree height stays `O(log n)`, then setting each node's
  /// [_Node.maxHigh] bottom-up.
  _Node<T>? _build(List<IntervalEntry<T>> sorted, int lo, int hi) {
    if (lo > hi) {
      return null;
    }
    final int mid = (lo + hi) >> 1;
    final _Node<T> node = _Node<T>(sorted[mid])
      ..left = _build(sorted, lo, mid - 1)
      ..right = _build(sorted, mid + 1, hi);
    node.maxHigh = math.max(
      node.entry.high,
      math.max(_subtreeMax(node.left), _subtreeMax(node.right)),
    );
    return node;
  }

  /// The subtree's `maxHigh`, or negative infinity for an absent child so it
  /// never wins the `max`.
  num _subtreeMax(_Node<T>? node) => node?.maxHigh ?? double.negativeInfinity;

  /// In-order walk collecting every overlap, pruning branches via [_Node.maxHigh]
  /// (left) and the node's own `low` (right).
  void _collect(_Node<T>? node, num low, num high, List<IntervalEntry<T>> out) {
    // No interval in this subtree reaches `low`, so none can overlap.
    if (node == null || node.maxHigh < low) {
      return;
    }
    _collect(node.left, low, high, out);
    if (node.entry.overlaps(low, high)) {
      out.add(node.entry);
    }
    // Right-subtree intervals all start at or after this node's `low`; if that
    // is already past `high`, none of them can overlap.
    if (node.entry.low <= high) {
      _collect(node.right, low, high, out);
    }
  }

  /// Same pruning as [_collect] but returns on the first overlap found.
  bool _anyOverlap(_Node<T>? node, num low, num high) {
    if (node == null || node.maxHigh < low) {
      return false;
    }
    if (_anyOverlap(node.left, low, high)) {
      return true;
    }
    if (node.entry.overlaps(low, high)) {
      return true;
    }
    return node.entry.low <= high && _anyOverlap(node.right, low, high);
  }
}
