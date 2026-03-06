import 'package:meta/meta.dart';

/// Invert map (K->V to V->K). Handles collisions by taking last.
extension MapInvertExtensions<K, V> on Map<K, V> {
  /// Inverts keys and values. On duplicate values, last key wins.
  @useResult
  Map<V, K> invert() {
    final Map<V, K> out = <V, K>{};
    for (final MapEntry<K, V> e in entries) {
      out[e.value] = e.key;
    }
    return out;
  }
}
