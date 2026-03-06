import 'package:meta/meta.dart';

/// Merge list of maps.
extension MapMergeListExtensions<K, V> on List<Map<K, V>> {
  /// Merges all maps; later maps overwrite earlier for same key.
  @useResult
  Map<K, V> mergeAll() {
    final Map<K, V> out = <K, V>{};
    for (final Map<K, V> m in this) {
      out.addAll(m);
    }
    return out;
  }
}
