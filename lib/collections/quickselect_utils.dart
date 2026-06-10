/// Quickselect: the k-th smallest/largest element without fully sorting.
/// Roadmap #52.
library;

/// Returns the element that would sit at 0-based index [k] if [items] were
/// sorted by [compare], without paying for a full sort.
///
/// Quickselect averages O(n) versus O(n log n) for sort-then-index, which
/// matters when you need a single order statistic (median, 90th percentile,
/// 2nd smallest) from a large collection. Partitions a private copy, so
/// [items] is never mutated.
///
/// Returns `null` when [k] is out of range (`k < 0` or `k >= length`) rather
/// than throwing, so the empty / bad-index case is handled at the call site.
///
/// Example:
/// ```dart
/// nthSmallest<int>([7, 2, 5, 1], 1, (a, b) => a.compareTo(b)); // 2 (2nd smallest)
/// ```
T? nthSmallest<T>(Iterable<T> items, int k, Comparator<T> compare) {
  final List<T> a = items.toList();
  if (k < 0 || k >= a.length) {
    return null;
  }

  int lo = 0;
  int hi = a.length - 1;
  while (lo < hi) {
    final int pivotIndex = _partition(a, lo, hi, compare);
    if (pivotIndex == k) {
      break;
    }
    // Recurse into only the side that contains rank k — this is what makes
    // quickselect linear on average rather than sorting both halves.
    if (pivotIndex < k) {
      lo = pivotIndex + 1;
    } else {
      hi = pivotIndex - 1;
    }
  }
  return a[k];
}

/// Returns the [k]-th largest element (0-based: `k = 0` is the maximum), or
/// `null` if [k] is out of range. Equivalent to `nthSmallest` from the other
/// end.
T? nthLargest<T>(Iterable<T> items, int k, Comparator<T> compare) =>
    nthSmallest(items, k, (T a, T b) => compare(b, a));

/// Lomuto partition around a median-of-three pivot, returning the pivot's
/// final index. Median-of-three avoids the O(n^2) worst case on already-sorted
/// or reverse-sorted input that a naive first/last pivot would hit.
int _partition<T>(List<T> a, int lo, int hi, Comparator<T> compare) {
  final int mid = lo + (hi - lo) ~/ 2;
  _medianOfThreeToHi(a, lo, mid, hi, compare);

  final T pivot = a[hi];
  int store = lo;
  for (int i = lo; i < hi; i++) {
    if (compare(a[i], pivot) < 0) {
      _swap(a, i, store);
      store++;
    }
  }
  _swap(a, store, hi);
  return store;
}

/// Orders the lo/mid/hi triple and parks the median at [hi] for use as pivot.
void _medianOfThreeToHi<T>(List<T> a, int lo, int mid, int hi, Comparator<T> compare) {
  if (compare(a[mid], a[lo]) < 0) _swap(a, lo, mid);
  if (compare(a[hi], a[lo]) < 0) _swap(a, lo, hi);
  // After the two swaps above, a[lo] is the smallest; put the median at hi.
  if (compare(a[mid], a[hi]) < 0) _swap(a, mid, hi);
}

void _swap<T>(List<T> a, int i, int j) {
  final T tmp = a[i];
  a[i] = a[j];
  a[j] = tmp;
}
