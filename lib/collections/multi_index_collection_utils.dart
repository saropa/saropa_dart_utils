/// Multi-index collection — roadmap #505.
///
/// An in-memory table that maintains several secondary indexes at once, so the
/// same items can be looked up by different keys in O(1) instead of scanning.
/// Think a list of users queried by id, by email, AND by city — each query hits
/// a hash index rather than a linear filter. Indexes are non-unique by default
/// (a key maps to a list); `getOneBy` is the convenience for unique indexes.
///
/// Distinct from `buildInvertedIndex` (a text term→document search index) and
/// the row/column table converters (shape transforms): this keeps live,
/// mutable, multi-key indexes over a set of records.
library;

import 'package:collection/collection.dart' show IterableExtension;

/// A collection of [T] indexed by one or more named key extractors. Add/remove
/// keep every index in sync. Index keys must be non-null and stable for an
/// item's lifetime in the collection (mutating an indexed field after insert
/// desyncs the index — remove then re-add instead).
class MultiIndexCollection<T> {
  /// Creates a collection whose [indexers] map an index name to a key extractor
  /// (e.g. `{'email': (u) => u.email, 'city': (u) => u.city}`). At least one
  /// index is required.
  MultiIndexCollection(Map<String, Object Function(T)> indexers)
    : assert(indexers.isNotEmpty, 'at least one index is required'),
      _indexers = Map<String, Object Function(T)>.unmodifiable(indexers),
      _indexes = <String, Map<Object, List<T>>>{
        for (final String name in indexers.keys) name: <Object, List<T>>{},
      };

  final Map<String, Object Function(T)> _indexers;
  final Map<String, Map<Object, List<T>>> _indexes;
  final List<T> _items = <T>[];

  /// Total number of items held.
  int get length => _items.length;

  /// Whether the collection is empty.
  bool get isEmpty => _items.isEmpty;

  /// The configured index names.
  Iterable<String> get indexNames => _indexers.keys;

  /// All items in insertion order (an unmodifiable view).
  List<T> get all => List<T>.unmodifiable(_items);

  /// Adds [item], updating every index.
  void add(T item) {
    _items.add(item);
    for (final MapEntry<String, Object Function(T)> entry in _indexers.entries) {
      final Map<Object, List<T>>? buckets = _indexes[entry.key];
      buckets?.putIfAbsent(entry.value(item), () => <T>[]).add(item);
    }
  }

  /// Adds every item in [items].
  void addAll(Iterable<T> items) {
    for (final T item in items) {
      add(item);
    }
  }

  /// Items whose [index] key equals [key], as an unmodifiable list (empty if
  /// none). Throws [ArgumentError] for an unknown [index] name.
  List<T> getBy(String index, Object key) {
    final Map<Object, List<T>>? buckets = _indexes[index];
    if (buckets == null) {
      throw ArgumentError.value(index, 'index', 'unknown index');
    }
    return List<T>.unmodifiable(buckets[key] ?? const <Never>[]);
  }

  /// The first item whose [index] key equals [key], or null. The convenience for
  /// a unique index. Throws [ArgumentError] for an unknown [index] name.
  T? getOneBy(String index, Object key) => getBy(index, key).firstOrNull;

  /// Whether any item has [key] under [index]. Throws for an unknown [index].
  bool containsKey(String index, Object key) => getBy(index, key).isNotEmpty;

  /// Removes [item] (matched by `==`) from the collection and every index.
  /// Returns whether it was present. A bucket left empty is pruned so the index
  /// doesn't accumulate dead keys.
  bool remove(T item) {
    if (!_items.remove(item)) {
      return false;
    }
    for (final MapEntry<String, Object Function(T)> entry in _indexers.entries) {
      final Map<Object, List<T>>? buckets = _indexes[entry.key];
      final Object key = entry.value(item);
      final List<T>? bucket = buckets?[key];
      if (bucket == null) {
        continue;
      }
      bucket.remove(item);
      if (bucket.isEmpty) {
        buckets?.remove(key);
      }
    }
    return true;
  }

  @override
  String toString() => 'MultiIndexCollection(length: $length, indexes: ${indexNames.toList()})';
}
