import 'package:meta/meta.dart';

/// Map values, map keys, filter by key/value.
extension MapTransformExtensions<K, V> on Map<K, V> {
  /// New map with same keys, values transformed by [f].
  @useResult
  Map<K, U> mapValues<U>(U Function(V value) f) =>
      Map<K, U>.fromEntries(entries.map((MapEntry<K, V> e) => MapEntry<K, U>(e.key, f(e.value))));

  /// New map with same values, keys transformed by [f]. Collisions: last wins.
  @useResult
  Map<U, V> mapKeys<U>(U Function(K key) f) =>
      Map<U, V>.fromEntries(entries.map((MapEntry<K, V> e) => MapEntry<U, V>(f(e.key), e.value)));

  /// New map with only entries where [keyPredicate](key) is true.
  @useResult
  Map<K, V> filterKeys(bool Function(K key) keyPredicate) =>
      Map<K, V>.fromEntries(entries.where((MapEntry<K, V> e) => keyPredicate(e.key)));

  /// New map with only entries where [valuePredicate](value) is true.
  @useResult
  Map<K, V> filterValues(bool Function(V value) valuePredicate) =>
      Map<K, V>.fromEntries(entries.where((MapEntry<K, V> e) => valuePredicate(e.value)));
}
