/// Weighted random subset selection without replacement — roadmap #476.
///
/// Picks up to `count` distinct items from a list where each item's chance of
/// selection is proportional to its weight, with no item chosen twice, and with
/// arbitrary items excluded outright. Naive weighted sampling without
/// replacement is awkward (re-normalizing after each draw is `O(n)` per pick);
/// this uses the Efraimidis-Spirakis one-pass reservoir trick: give each
/// eligible item a key `random^(1/weight)` and keep the `count` items with the
/// largest keys. A higher weight pushes the key toward 1, so heavier items win
/// more often — and a single pass yields a correct weighted sample.
///
/// Randomness is injectable via [Random] so callers can seed it for
/// deterministic, testable selection.
library;

import 'dart:math';

/// One eligible item paired with its Efraimidis-Spirakis selection key.
class _KeyedItem<T> {
  _KeyedItem(this.item, this.key);

  final T item;

  /// `random^(1/weight)`; the `count` largest keys form the chosen subset.
  final double key;
}

/// Selects up to [count] distinct items from [items], weighted by [weight],
/// without replacement.
///
/// Rules:
/// - Items in [exclude] are skipped entirely.
/// - Items whose [weight] is `<= 0` (or non-finite) are never chosen.
/// - [count] is clamped to the number of eligible items, so the result holds
///   exactly `min(count, eligible)` items (an empty list when nothing qualifies).
///
/// Uses the Efraimidis-Spirakis algorithm: each eligible item gets the key
/// `random^(1/weight)` and the items with the [count] largest keys are returned.
/// Pass a seeded [random] for deterministic output. Result order is by
/// descending key (most strongly selected first), not input order.
///
/// Example:
/// ```dart
/// final List<String> picked = weightedSubset<String>(
///   <String>['a', 'b', 'c'],
///   count: 2,
///   weight: (String s) => s == 'a' ? 10 : 1, // 'a' favored
///   random: Random(7),
/// );
/// // picked.length == 2; 'a' chosen far more often across seeds
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<T> weightedSubset<T>(
  List<T> items, {
  required int count,
  required double Function(T) weight,
  Set<T> exclude = const <Never>{},
  Random? random,
}) {
  if (count <= 0) return <T>[];
  final Random rng = random ?? Random();
  final List<_KeyedItem<T>> keyed = _keyEligible<T>(items, weight, exclude, rng);
  // Largest keys first; clamp the take to however many items actually qualified.
  keyed.sort((_KeyedItem<T> a, _KeyedItem<T> b) => b.key.compareTo(a.key));
  final int take = count < keyed.length ? count : keyed.length;
  return <T>[for (int i = 0; i < take; i++) keyed[i].item];
}

/// Builds the keyed list of eligible items, skipping excluded items and any with
/// a non-positive or non-finite weight (which can never be sampled).
/// Audited: 2026-06-12 11:26 EDT
List<_KeyedItem<T>> _keyEligible<T>(
  List<T> items,
  double Function(T) weight,
  Set<T> exclude,
  Random rng,
) {
  final List<_KeyedItem<T>> keyed = <_KeyedItem<T>>[];
  // Single pass that assigns every surviving item its sampling key.
  for (final T item in items) {
    if (exclude.contains(item)) continue;
    final double w = weight(item);
    // A zero/negative/NaN weight means zero probability, so drop the item.
    if (!w.isFinite || w <= 0) continue;
    keyed.add(_KeyedItem<T>(item, _selectionKey(w, rng)));
  }
  return keyed;
}

/// The Efraimidis-Spirakis key `u^(1/weight)` for a uniform `u` in `(0, 1]`.
/// Computed as `exp(ln(u) / weight)` for numerical stability with large weights.
/// Audited: 2026-06-12 11:26 EDT
double _selectionKey(double weight, Random rng) {
  // nextDouble() is in [0, 1); shift to (0, 1] so ln(u) is always finite.
  final double u = 1.0 - rng.nextDouble();
  return exp(log(u) / weight);
}
