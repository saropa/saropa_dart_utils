/// Min-max heap: a double-ended priority queue — roadmap #499.
///
/// Supports `O(log n)` insert and `O(log n)` removal of BOTH the minimum and
/// the maximum, plus `O(1)` peeks at each end. A plain binary heap gives you
/// only one end cheaply (min OR max); getting the other end is `O(n)`. The
/// min-max heap interleaves the two orderings by level: nodes on even
/// (min) levels are <= all of their descendants, and nodes on odd (max) levels
/// are >= all of their descendants. The root is therefore the global minimum,
/// and the larger of its (at most two) children is the global maximum.
///
/// Stored as an implicit binary heap in a `0`-based list, so the children of
/// node `i` are `2i+1` and `2i+2` and the parent is `(i-1) >> 1`. Ordering is
/// supplied by a [Comparator]; equal elements are allowed.
library;

import 'package:collection/collection.dart';

/// A double-ended priority queue backed by a min-max heap.
class MinMaxHeap<T> {
  /// Creates an empty heap ordered by [compare].
  /// Audited: 2026-06-12 11:26 EDT
  MinMaxHeap(this._compare);

  final Comparator<T> _compare;
  final List<T> _items = <T>[];

  /// Number of elements in the heap.
  /// Audited: 2026-06-12 11:26 EDT
  int get length => _items.length;

  /// Whether the heap holds no elements.
  /// Audited: 2026-06-12 11:26 EDT
  bool get isEmpty => _items.isEmpty;

  /// The smallest element without removing it.
  /// Throws [StateError] when the heap is empty.
  /// Audited: 2026-06-12 11:26 EDT
  T get min {
    if (_items.isEmpty) throw StateError('min on an empty MinMaxHeap');
    // The root of a min-max heap is always the global minimum; the guard above
    // proves the list is non-empty, so .first cannot throw.
    return _items.first;
  }

  /// The largest element without removing it.
  /// Throws [StateError] when the heap is empty.
  /// Audited: 2026-06-12 11:26 EDT
  T get max {
    if (_items.isEmpty) throw StateError('max on an empty MinMaxHeap');
    return _items[_maxIndex()];
  }

  /// The smallest element, or null when empty.
  /// Audited: 2026-06-12 11:26 EDT
  T? get minOrNull => _items.firstOrNull;

  /// The largest element, or null when empty.
  /// Audited: 2026-06-12 11:26 EDT
  T? get maxOrNull => _items.isEmpty ? null : _items[_maxIndex()];

  /// Inserts [value], in `O(log n)`.
  ///
  /// Example:
  /// ```dart
  /// final MinMaxHeap<int> h = MinMaxHeap<int>((int a, int b) => a.compareTo(b));
  /// h..add(5)..add(1)..add(9);
  /// h.removeMin(); // 1
  /// h.removeMax(); // 9
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  void add(T value) {
    _items.add(value);
    _trickleUp(_items.length - 1);
  }

  /// Removes and returns the smallest element, in `O(log n)`.
  /// Throws [StateError] when the heap is empty.
  /// Audited: 2026-06-12 11:26 EDT
  T removeMin() {
    if (_items.isEmpty) throw StateError('removeMin on an empty MinMaxHeap');
    // Root holds the min; swap the last element in and sink it back down.
    return _removeAt(0);
  }

  /// Removes and returns the largest element, in `O(log n)`.
  /// Throws [StateError] when the heap is empty.
  /// Audited: 2026-06-12 11:26 EDT
  T removeMax() {
    if (_items.isEmpty) throw StateError('removeMax on an empty MinMaxHeap');
    return _removeAt(_maxIndex());
  }

  /// Index of the maximum: the root when the heap has one element, otherwise the
  /// larger of the (one or two) children on the max level.
  /// Audited: 2026-06-12 11:26 EDT
  int _maxIndex() {
    if (_items.length == 1) return 0;
    if (_items.length == 2) return 1;
    // Two children exist (indices 1 and 2); pick whichever is larger.
    return _compare(_items[1], _items[2]) >= 0 ? 1 : 2;
  }

  /// Removes the element at [index] by moving the last item into its slot and
  /// re-establishing the heap order from there.
  /// Audited: 2026-06-12 11:26 EDT
  T _removeAt(int index) {
    final T removed = _items[index];
    final T last = _items.removeLast();
    // If we removed the last slot itself, nothing remains to reinsert.
    if (index < _items.length) {
      _items[index] = last;
      _trickleDown(index);
    }
    return removed;
  }

  /// Whether [level] (0-based depth) is a min level. Even levels are min levels.
  /// Audited: 2026-06-12 11:26 EDT
  bool _isMinLevel(int level) => level.isEven;

  /// Depth of node [index]: floor(log2(index + 1)).
  /// Audited: 2026-06-12 11:26 EDT
  int _levelOf(int index) {
    int level = 0;
    int i = index + 1;
    // Strip one bit per level until only the leading 1 remains.
    while (i > 1) {
      i >>= 1;
      level++;
    }
    return level;
  }

  /// Restores order after inserting at [index] by pushing it up toward whichever
  /// end (min or max) its level belongs to.
  /// Audited: 2026-06-12 11:26 EDT
  void _trickleUp(int index) {
    if (index == 0) return;
    final int parent = (index - 1) >> 1;
    if (_isMinLevel(_levelOf(index))) {
      // On a min level: if bigger than the parent (a max node), it belongs in
      // the max ordering, so swap up and continue there; else fix the min chain.
      if (_compare(_items[index], _items[parent]) > 0) {
        _swap(index, parent);
        _trickleUpToward(parent, max: true);
      } else {
        _trickleUpToward(index, max: false);
      }
    } else {
      if (_compare(_items[index], _items[parent]) < 0) {
        _swap(index, parent);
        _trickleUpToward(parent, max: false);
      } else {
        _trickleUpToward(index, max: true);
      }
    }
  }

  /// Bubbles [index] up to its same-kind grandparent while it violates the
  /// min (max == false) or max (max == true) ordering. The grandparent sits two
  /// levels up, so it shares this node's level kind.
  /// Audited: 2026-06-12 11:26 EDT
  void _trickleUpToward(int index, {required bool max}) {
    int i = index;
    // A grandparent exists only once the index is past the first three slots
    // (root + its two children); below that there is nothing two levels up.
    while (i > 2) {
      final int grandparent = (((i - 1) >> 1) - 1) >> 1;
      final int cmp = _compare(_items[i], _items[grandparent]);
      // Stop as soon as the same-kind ordering against the grandparent holds.
      if (max ? cmp <= 0 : cmp >= 0) break;
      _swap(i, grandparent);
      i = grandparent;
    }
  }

  /// Restores order after a removal by sinking [index] toward the leaves on its
  /// own level kind (min or max).
  /// Audited: 2026-06-12 11:26 EDT
  void _trickleDown(int index) {
    if (_isMinLevel(_levelOf(index))) {
      _trickleDownToward(index, max: false);
    } else {
      _trickleDownToward(index, max: true);
    }
  }

  /// Sinks [index] down, swapping with the most extreme child-or-grandchild
  /// (smallest for a min level, largest for a max level) until order holds.
  /// Audited: 2026-06-12 11:26 EDT
  void _trickleDownToward(int index, {required bool max}) {
    int i = index;
    // Each iteration finds the extreme descendant within two levels of i.
    while (true) {
      final int m = _extremeDescendant(i, max: max);
      if (m < 0) break;
      final int cmp = _compare(_items[m], _items[i]);
      if (max ? cmp <= 0 : cmp >= 0) break;
      _swap(i, m);
      // A grandchild swap may break the parent ordering; fix and continue.
      if (m > 2 * i + 2) {
        final int parent = (m - 1) >> 1;
        final int pc = _compare(_items[m], _items[parent]);
        if (max ? pc < 0 : pc > 0) _swap(m, parent);
        i = m;
      } else {
        break;
      }
    }
  }

  /// Index of the most extreme (smallest when max == false, largest when
  /// max == true) among the children and grandchildren of [index], or -1 if
  /// [index] has no children.
  /// Audited: 2026-06-12 11:26 EDT
  int _extremeDescendant(int index, {required bool max}) {
    final List<int> kin = <int>[];
    final int left = 2 * index + 1;
    final int right = 2 * index + 2;
    // Collect the two children and up to four grandchildren that exist.
    for (final int c in <int>[left, right]) {
      if (c >= _items.length) continue;
      kin.add(c);
      for (final int g in <int>[2 * c + 1, 2 * c + 2]) {
        if (g < _items.length) kin.add(g);
      }
    }
    if (kin.isEmpty) return -1;
    // The guard above proves kin is non-empty, so .first cannot throw.
    int best = kin.first;
    // Pick the extreme: largest for a max level, smallest for a min level.
    for (final int k in kin) {
      final int cmp = _compare(_items[k], _items[best]);
      if (max ? cmp > 0 : cmp < 0) best = k;
    }
    return best;
  }

  /// Swaps the elements at [a] and [b].
  /// Audited: 2026-06-12 11:26 EDT
  void _swap(int a, int b) {
    final T tmp = _items[a];
    _items[a] = _items[b];
    _items[b] = tmp;
  }

  @override
  String toString() => 'MinMaxHeap(length: ${_items.length})';
}
