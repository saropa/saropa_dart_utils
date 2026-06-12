/// Lazy combinatorial generators — permutations, combinations, cartesian
/// product, power set (roadmap #488).
///
/// Every generator is a `sync*` iterable that produces results on demand: it
/// yields a fresh `List<T>` per result and computes the next only when the
/// caller asks for it. Nothing is materialized up front, so you can iterate the
/// permutations of a large set, `take` the first few, or stop early without
/// paying for the full (often factorial-sized) enumeration. Each yielded list
/// is a new instance the caller may keep or mutate freely.
library;

/// Lazily yields every ordering of [items], or every ordered arrangement of
/// [length] items drawn from [items] when [length] is given.
///
/// With no [length] this is the full set of `n!` permutations. With a
/// [length] of `k` it yields the `n!/(n-k)!` k-permutations. A [length] of 0
/// yields a single empty list; a [length] greater than `items.length` yields
/// nothing. Order is deterministic (lexicographic by source index).
///
/// Example:
/// ```dart
/// for (final List<int> p in permutations<int>(<int>[1, 2, 3])) {
///   print(p); // [1,2,3], [1,3,2], [2,1,3], ...
/// }
/// ```
/// Audited: 2026-06-12 11:26 EDT
Iterable<List<T>> permutations<T>(List<T> items, {int? length}) sync* {
  final int k = length ?? items.length;
  // A negative or oversized length can produce nothing; 0 yields one empty
  // arrangement (the empty product), matching the math convention.
  if (k < 0 || k > items.length) {
    return;
  }
  yield* _permute<T>(items, k, <int>[], List<bool>.filled(items.length, false));
}

/// Recursive helper that grows [chosen] (a list of source indices) until it
/// holds [k] entries, marking used positions in [used] so each index appears
/// at most once per arrangement.
/// Audited: 2026-06-12 11:26 EDT
Iterable<List<T>> _permute<T>(
  List<T> items,
  int k,
  List<int> chosen,
  List<bool> used,
) sync* {
  // Base case: a full-length arrangement — emit a fresh list of its values.
  if (chosen.length == k) {
    yield <T>[for (final int i in chosen) items[i]];
    return;
  }
  // Extend by every still-unused index, recursing then undoing the choice.
  for (int i = 0; i < items.length; i++) {
    if (used[i]) {
      continue;
    }
    used[i] = true;
    chosen.add(i);
    yield* _permute<T>(items, k, chosen, used);
    chosen.removeLast();
    used[i] = false;
  }
}

/// Lazily yields every [k]-element combination of [items] (order within a
/// combination follows source order; combinations themselves are in
/// lexicographic index order).
///
/// `k == 0` yields a single empty combination; `k > items.length` yields
/// nothing. There are `nCk` results in total.
///
/// Example:
/// ```dart
/// combinations<int>(<int>[1, 2, 3, 4], 2); // [1,2],[1,3],[1,4],[2,3],...
/// ```
/// Audited: 2026-06-12 11:26 EDT
Iterable<List<T>> combinations<T>(List<T> items, int k) sync* {
  // Out-of-range k has no combinations; k == 0 falls through to yield [].
  if (k < 0 || k > items.length) {
    return;
  }
  yield* _combine<T>(items, k, 0, <int>[]);
}

/// Recursive helper that picks increasing source indices into [chosen] starting
/// at [start], so each combination is generated once in index order.
/// Audited: 2026-06-12 11:26 EDT
Iterable<List<T>> _combine<T>(
  List<T> items,
  int k,
  int start,
  List<int> chosen,
) sync* {
  // Base case: enough indices picked — emit a fresh list of their values.
  if (chosen.length == k) {
    yield <T>[for (final int i in chosen) items[i]];
    return;
  }
  // Only consider indices at/after `start` to avoid duplicate combinations.
  for (int i = start; i < items.length; i++) {
    chosen.add(i);
    yield* _combine<T>(items, k, i + 1, chosen);
    chosen.removeLast();
  }
}

/// Lazily yields every cartesian product of the input [lists]: one element
/// chosen from each list, in order. The number of results is the product of
/// the list lengths (so an empty [lists] yields one empty tuple, and any empty
/// inner list makes the product empty).
///
/// Example:
/// ```dart
/// cartesianProduct<int>(<List<int>>[<int>[1, 2], <int>[3, 4]]);
/// // [1,3], [1,4], [2,3], [2,4]
/// ```
/// Audited: 2026-06-12 11:26 EDT
Iterable<List<T>> cartesianProduct<T>(List<List<T>> lists) sync* {
  yield* _product<T>(lists, 0, <T>[]);
}

/// Recursive helper that fixes one element from `lists[depth]` into [prefix]
/// before recursing into the next list, emitting a full tuple at the leaves.
/// Audited: 2026-06-12 11:26 EDT
Iterable<List<T>> _product<T>(
  List<List<T>> lists,
  int depth,
  List<T> prefix,
) sync* {
  // Base case: a choice has been made from every list — emit a fresh tuple.
  if (depth == lists.length) {
    yield <T>[...prefix];
    return;
  }
  // Branch on each option at this depth; an empty list here yields nothing.
  for (final T option in lists[depth]) {
    prefix.add(option);
    yield* _product<T>(lists, depth + 1, prefix);
    prefix.removeLast();
  }
}

/// Lazily yields every subset of [items] (the power set), from the empty set up
/// to the full set, ordered by increasing subset size then lexicographically.
/// There are `2^n` subsets.
///
/// Example:
/// ```dart
/// powerSet<int>(<int>[1, 2]); // [], [1], [2], [1,2]
/// ```
/// Audited: 2026-06-12 11:26 EDT
Iterable<List<T>> powerSet<T>(List<T> items) sync* {
  // Emit subsets grouped by size so the empty set comes first and the full set
  // last; each size delegates to the lazy combinations generator.
  for (int size = 0; size <= items.length; size++) {
    yield* combinations<T>(items, size);
  }
}
