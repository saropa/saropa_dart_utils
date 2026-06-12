/// Shallow copy list/map. Roadmap #207.
library;

/// Returns a new list with the same elements as [source]. Elements are shared
/// by reference (not deep-copied).
///
/// Example:
/// ```dart
/// shallowCopyList([1, 2, 3]); // a new [1, 2, 3]
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<T> shallowCopyList<T>(List<T> source) => List<T>.of(source);

/// Returns a new map with the same entries as [source]. Keys and values are
/// shared by reference (not deep-copied).
///
/// Example:
/// ```dart
/// shallowCopyMap({'a': 1}); // a new {'a': 1}
/// ```
/// Audited: 2026-06-12 11:26 EDT
Map<K, V> shallowCopyMap<K, V>(Map<K, V> source) => Map<K, V>.of(source);
