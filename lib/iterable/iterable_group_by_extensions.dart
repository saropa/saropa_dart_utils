import 'package:meta/meta.dart';

/// Group by key with optional value transform.
extension IterableGroupByTransformExtensions<T> on Iterable<T> {
  /// Groups by [keyOf] and transforms values with [valueTransform].
  /// Returns Map<K, List<U>>.
  @useResult
  Map<K, List<U>> groupByTransform<K, U>(K Function(T) keyOf, U Function(T) valueTransform) {
    final Map<K, List<U>> result = <K, List<U>>{};
    for (final T element in this) {
      final K key = keyOf(element);
      result.putIfAbsent(key, () => <U>[]).add(valueTransform(element));
    }
    return result;
  }
}
