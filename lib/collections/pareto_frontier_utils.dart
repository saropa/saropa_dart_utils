/// Pareto frontier / dominance filtering in 2-3 dimensions — roadmap #463.
library;

/// Optimization direction for a single Pareto objective.
///
/// [minimize] treats smaller values as better (e.g. cost, latency);
/// [maximize] treats larger values as better (e.g. quality, profit).
enum ParetoDirection {
  /// Smaller objective values dominate larger ones.
  minimize,

  /// Larger objective values dominate smaller ones.
  maximize,
}

/// Extractors + directions describing how to score items on each objective.
///
/// Bundled as one config object so [paretoFrontier] keeps to a small parameter
/// count even with multiple objectives; [criteria] and [directions] must be the
/// same length and define the objective space in matching order.
///
/// Example:
/// ```dart
/// final opts = ParetoOptions<Offer>(
///   criteria: [(o) => o.price, (o) => o.rating],
///   directions: [ParetoDirection.minimize, ParetoDirection.maximize],
/// );
/// ```
class ParetoOptions<T> {
  // Private const constructor: validation happens in the factory so a failed
  // check never leaves a half-built options object (avoid_exception_in_constructor).
  const ParetoOptions._(this.criteria, this.directions);

  /// Creates options; throws [ArgumentError] when lengths mismatch or are empty.
  ///
  /// A length mismatch would silently ignore objectives or read past the end
  /// during dominance checks, so it is rejected up front rather than mid-scan.
  /// Audited: 2026-06-12 11:26 EDT
  factory ParetoOptions({
    // ignore: prefer_correct_callback_field_name -- objective extractors, not event handlers; on-prefix does not apply
    required List<num Function(T item)> criteria,
    required List<ParetoDirection> directions,
  }) {
    if (criteria.isEmpty || criteria.length != directions.length) {
      throw ArgumentError('criteria and directions must be non-empty and equal length');
    }
    return ParetoOptions<T>._(criteria, directions);
  }

  /// One value extractor per objective, in objective order.
  // ignore: prefer_correct_callback_field_name -- objective extractors, not event handlers; on-prefix does not apply
  final List<num Function(T item)> criteria;

  /// One direction per objective, aligned with [criteria].
  final List<ParetoDirection> directions;
}

/// Returns the non-dominated (Pareto-optimal) subset of [items], order preserved.
///
/// A point dominates another when it is no worse on every objective and strictly
/// better on at least one. All-equal points (including duplicates) never dominate
/// each other, so they are all kept. Empty input yields an empty list; a single
/// item is always non-dominated.
///
/// Example:
/// ```dart
/// final opts = ParetoOptions<List<int>>(
///   criteria: [(p) => p[0], (p) => p[1]],
///   directions: [ParetoDirection.minimize, ParetoDirection.minimize],
/// );
/// paretoFrontier([[1, 2], [2, 1], [3, 3]], opts); // [[1, 2], [2, 1]]
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<T> paretoFrontier<T>(List<T> items, ParetoOptions<T> options) {
  // Precompute every item's objective vector once; recomputing inside the
  // quadratic dominance scan would re-run the user's extractors for every pair.
  final List<List<num>> scores = items
      .map((item) => options.criteria.map((extract) => extract(item)).toList())
      .toList();
  final List<T> frontier = <T>[];
  // Keep item i only if no other item dominates it; ties and duplicates survive
  // because _dominates requires a strict improvement on some objective.
  for (int i = 0; i < items.length; i++) {
    if (!_anyDominates(scores, i, options.directions)) {
      frontier.add(items[i]);
    }
  }
  return frontier;
}

/// True when any item other than [target] dominates the item at [target].
/// Audited: 2026-06-12 11:26 EDT
bool _anyDominates(List<List<num>> scores, int target, List<ParetoDirection> dirs) {
  for (int j = 0; j < scores.length; j++) {
    if (j != target && _dominates(scores[j], scores[target], dirs)) return true;
  }
  return false;
}

/// True when vector [a] dominates [b]: no worse on all objectives, better on one.
/// Audited: 2026-06-12 11:26 EDT
bool _dominates(List<num> a, List<num> b, List<ParetoDirection> dirs) {
  bool strictlyBetter = false;
  for (int k = 0; k < dirs.length; k++) {
    // Normalize so "larger is better" for both directions, then a single set of
    // comparisons covers minimize and maximize without branching per direction.
    final num av = dirs[k] == ParetoDirection.minimize ? -a[k] : a[k];
    final num bv = dirs[k] == ParetoDirection.minimize ? -b[k] : b[k];
    if (av < bv) return false;
    if (av > bv) strictlyBetter = true;
  }
  return strictlyBetter;
}
