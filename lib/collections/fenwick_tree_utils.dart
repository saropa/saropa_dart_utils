/// Fenwick tree (Binary Indexed Tree) for prefix sums — roadmap #483.
///
/// Maintains a mutable array of `num` and answers prefix-sum and range-sum
/// queries in `O(log n)`, with `O(log n)` point updates. A plain array does
/// either reads OR writes cheaply but not both: a prefix-sum cache makes
/// queries `O(1)` but every update `O(n)`, while a raw array makes updates
/// `O(1)` but every prefix sum `O(n)`. The Fenwick tree balances both at
/// `O(log n)` by storing partial sums over power-of-two-aligned ranges.
///
/// The internal tree is 1-based (index 0 is an unused sentinel that lets the
/// `i & -i` lowest-set-bit walk terminate), while the public API is 0-based and
/// inclusive on both ends, so `rangeSum(2, 4)` sums elements 2, 3, and 4.
library;

/// A Binary Indexed Tree over `num` supporting point updates and range sums.
class FenwickTree {
  /// Creates a tree of [size] elements, all initialized to zero.
  /// Requires `size >= 0`.
  /// Audited: 2026-06-12 11:26 EDT
  FenwickTree(int size)
    : _size = _validatedSize(size),
      // One extra slot because the tree is 1-based; index 0 stays unused.
      _tree = List<num>.filled(size + 1, 0);

  // Enforced in release (an assert strips): a size of -1 otherwise slips past
  // the filled-array allocation and builds an unusable tree. A static helper in
  // the initializer keeps the throw out of the constructor body, which the
  // avoid_exception_in_constructor lint forbids.
  static int _validatedSize(int size) {
    if (size < 0) {
      throw ArgumentError.value(size, 'size', 'must be >= 0');
    }
    return size;
  }

  /// Creates a tree seeded with [values], in `O(n)`.
  /// Audited: 2026-06-12 11:26 EDT
  FenwickTree.fromList(List<num> values) : this._fromList(values);

  // Private delegate so the public factory body can run after the field
  // initializers (the build loop needs `_tree` and `_size` in place first).
  FenwickTree._fromList(List<num> values)
    : _size = values.length,
      _tree = List<num>.filled(values.length + 1, 0) {
    // Seed each element via update so partial sums propagate correctly.
    for (int i = 0; i < values.length; i++) {
      update(i, values[i]);
    }
  }

  final int _size;
  final List<num> _tree;

  /// Number of elements in the tree.
  /// Audited: 2026-06-12 11:26 EDT
  int get length => _size;

  /// Adds [delta] to the element at [index] (0-based), in `O(log n)`.
  /// Requires `0 <= index < length`.
  ///
  /// Example:
  /// ```dart
  /// final FenwickTree t = FenwickTree(5);
  /// t.update(2, 7); // element 2 becomes 7
  /// t.prefixSum(2); // 7
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  void update(int index, num delta) {
    // Must throw in release, not assert: a negative index makes `i & -i == 0`,
    // so `i += 0` below would loop forever — a production hang, not a no-op.
    if (index < 0 || index >= _size) {
      throw RangeError('index ($index) out of range [0, $_size)');
    }
    // Walk to each responsible node by adding the lowest set bit (i & -i).
    for (int i = index + 1; i <= _size; i += i & -i) {
      _tree[i] += delta;
    }
  }

  /// Sum of elements `[0..index]` inclusive (0-based), in `O(log n)`.
  /// Requires `0 <= index < length`.
  /// Audited: 2026-06-12 11:26 EDT
  num prefixSum(int index) {
    // Throw in release: an out-of-range index otherwise reads a stale partial
    // sum (high) or a wrong walk (negative), returning a silently bad total.
    if (index < 0 || index >= _size) {
      throw RangeError('index ($index) out of range [0, $_size)');
    }
    num sum = 0;
    // Walk toward the root by stripping the lowest set bit each step.
    for (int i = index + 1; i > 0; i -= i & -i) {
      sum += _tree[i];
    }
    return sum;
  }

  /// Sum of elements `[low..high]` inclusive (0-based), in `O(log n)`.
  /// Requires `0 <= low <= high < length`.
  ///
  /// Example:
  /// ```dart
  /// final FenwickTree t = FenwickTree.fromList(<num>[1, 2, 3, 4]);
  /// t.rangeSum(1, 3); // 9
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  num rangeSum(int low, int high) {
    // Throw in release: invalid bounds must not silently flow into the
    // prefixSum subtraction below and yield a meaningless range total.
    if (low < 0 || low > high) {
      throw RangeError('low ($low) must be in 0..high ($high)');
    }
    if (high >= _size) {
      throw RangeError('high ($high) out of range [0, $_size)');
    }
    // Subtract the prefix below `low`; when low is 0 there is nothing to remove.
    if (low == 0) {
      return prefixSum(high);
    }
    return prefixSum(high) - prefixSum(low - 1);
  }

  /// The current value at [index] (0-based), in `O(log n)`.
  /// Requires `0 <= index < length`.
  /// Audited: 2026-06-12 11:26 EDT
  num valueAt(int index) =>
      // Bounds are enforced by rangeSum, so no separate check is needed.
      // ignore: no_equal_arguments -- a single-element sum is the degenerate range [index, index]
      rangeSum(index, index);

  @override
  String toString() => 'FenwickTree(length: $_size)';
}
