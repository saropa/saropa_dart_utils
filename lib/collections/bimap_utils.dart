/// Bi-directional map (key↔value both unique) — roadmap #514.
library;

/// Simple bimap: forward and reverse lookup; keys and values must be unique.
class Bimap<K extends Object, V extends Object> {
  final Map<K, V> _forward = <K, V>{};
  final Map<V, K> _reverse = <V, K>{};

  /// Associates [key] with [value]; replaces any existing mapping for either.
  void put(K key, V value) {
    final V? previousValue = _forward[key];
    if (previousValue != null) _reverse.remove(previousValue);
    final K? previousKey = _reverse[value];
    if (previousKey != null) _forward.remove(previousKey);
    _forward[key] = value;
    _reverse[value] = key;
  }

  /// Value for [key], or null.
  V? get(K key) => _forward[key];

  /// Key for [value], or null.
  K? getKey(V value) => _reverse[value];

  /// Whether [key] is present.
  bool containsKey(K key) => _forward.containsKey(key);

  /// Whether [value] is present.
  bool containsValue(V value) => _reverse.containsKey(value);

  /// Removes the entry with the given key.
  void removeByKey(K key) {
    final V? v = _forward.remove(key);
    if (v != null) _reverse.remove(v);
  }

  /// Removes the entry with the given value.
  void removeByValue(V value) {
    final K? k = _reverse.remove(value);
    if (k != null) _forward.remove(k);
  }

  /// Number of key-value pairs.
  int get length => _forward.length;

  @override
  String toString() => 'Bimap(length: ${_forward.length})';
}
