/// Group and aggregate by several keys at once — roadmap #477.
library;

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// A composite grouping key built from several selector values.
///
/// A raw `List` cannot be a `Map` key because lists use identity equality —
/// two lists with equal contents are different keys. [MultiKey] gives the
/// tuple value equality (element-wise) and a matching hash, so grouping by
/// `(country, year)` collapses every row with the same pair into one bucket.
@immutable
class MultiKey {
  /// Wraps the ordered selector [values] that make up this composite key.
  const MultiKey(this.values);

  /// The selector values in selector order (e.g. `[country, year]`).
  final List<Object?> values;

  @override
  bool operator ==(Object other) =>
      other is MultiKey && const ListEquality<Object?>().equals(values, other.values);

  @override
  int get hashCode => Object.hashAll(values);

  @override
  String toString() => 'MultiKey($values)';
}

/// Groups [items] by applying every selector in [keys], bucketing rows whose
/// composite key is equal. Returns a map from [MultiKey] to the list of items
/// in that bucket, in first-seen insertion order.
///
/// Example:
/// ```dart
/// groupByKeys(rows, [(r) => r['country'], (r) => r['year']]);
/// ```
Map<MultiKey, List<T>> groupByKeys<T>(Iterable<T> items, List<Object? Function(T)> keys) {
  final Map<MultiKey, List<T>> out = <MultiKey, List<T>>{};
  for (final T item in items) {
    final MultiKey key = MultiKey(keys.map((Object? Function(T) f) => f(item)).toList());
    out.putIfAbsent(key, () => <T>[]).add(item);
  }
  return out;
}

/// Groups [items] by [keys] and reduces each bucket with [aggregator],
/// returning a map from composite key to the aggregate (e.g. a count, sum, or
/// average per `(country, year)`).
///
/// Example:
/// ```dart
/// aggregateByKeys(rows, [(r) => r['country']], (g) => g.length); // count
/// ```
Map<MultiKey, R> aggregateByKeys<T, R>(
  Iterable<T> items,
  List<Object? Function(T)> keys,
  R Function(List<T> group) aggregator,
) => groupByKeys(items, keys).map(
  (MultiKey key, List<T> group) => MapEntry<MultiKey, R>(key, aggregator(group)),
);
