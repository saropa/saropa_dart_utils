import 'package:meta/meta.dart';

/// Merge list of maps.
extension MapMergeListExtensions<K, V> on List<Map<K, V>> {
  /// Merges all maps; later maps overwrite earlier for same key.
  @useResult
  Map<K, V> mergeAll() {
    final Map<K, V> out = <K, V>{};
    for (final Map<K, V> m in this) {
      // ignore: saropa_lints/prefer_spread_over_addall -- accumulates across loop iterations; spread would be O(n^2)
      out.addAll(m);
    }
    return out;
  }
}
