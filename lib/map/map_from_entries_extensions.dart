import 'package:meta/meta.dart';

/// Map from list of entries / entries to list.
extension MapFromEntriesExtensions<K, V> on Map<K, V> {
  /// Returns entries as list of pairs.
  @useResult
  List<(K, V)> toEntriesList() =>
      entries.map<(K, V)>((MapEntry<K, V> e) => (e.key, e.value)).toList();
}

/// Build map from iterable of (key, value) pairs. Later pairs overwrite.
Map<K, V> mapFromEntries<K, V>(Iterable<(K, V)> entries) {
  final Map<K, V> out = <K, V>{};
  for (final (K k, V v) in entries) {
    out[k] = v;
  }
  return out;
}
