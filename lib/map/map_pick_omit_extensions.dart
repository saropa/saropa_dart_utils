import 'package:meta/meta.dart';

/// Pick and omit keys from maps.
extension MapPickOmitExtensions<K, V> on Map<K, V> {
  /// Returns a new map containing only entries whose keys are in [keys].
  @useResult
  Map<K, V> pick(Iterable<K> keys) {
    final Set<K> keySet = keys.toSet();
    return Map<K, V>.fromEntries(entries.where((MapEntry<K, V> e) => keySet.contains(e.key)));
  }

  /// Returns a new map containing all entries whose keys are not in [keys].
  @useResult
  Map<K, V> omit(Iterable<K> keys) {
    final Set<K> keySet = keys.toSet();
    return Map<K, V>.fromEntries(entries.where((MapEntry<K, V> e) => !keySet.contains(e.key)));
  }
}
