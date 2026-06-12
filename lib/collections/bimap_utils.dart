/// Bi-directional map (key↔value both unique) — roadmap #514.
library;

/// Simple bimap: forward and reverse lookup; keys and values must be unique.
class BimapUtils<K extends Object, V extends Object> {
  final Map<K, V> _forward = <K, V>{};
  final Map<V, K> _reverse = <V, K>{};

  /// Associates [key] with [value]; replaces any existing mapping for either.
  /// Audited: 2026-06-12 11:26 EDT
  void put(K key, V value) {
    final V? previousValue = _forward[key];
    if (previousValue != null) _reverse.remove(previousValue);
    final K? previousKey = _reverse[value];
    if (previousKey != null) _forward.remove(previousKey);
    _forward[key] = value;
    _reverse[value] = key;
  }

  /// Value for [key], or null.
  /// Audited: 2026-06-12 11:26 EDT
  V? get(K key) => _forward[key];

  /// Key for [value], or null.
  /// Audited: 2026-06-12 11:26 EDT
  K? getKey(V value) => _reverse[value];

  /// Whether [key] is present.
  /// Audited: 2026-06-12 11:26 EDT
  bool containsKey(K key) => _forward.containsKey(key);

  /// Whether [value] is present.
  /// Audited: 2026-06-12 11:26 EDT
  bool containsValue(V value) => _reverse.containsKey(value);

  /// Removes the entry with the given key.
  /// Audited: 2026-06-12 11:26 EDT
  void removeByKey(K key) {
    final V? v = _forward.remove(key);
    if (v != null) _reverse.remove(v);
  }

  /// Removes the entry with the given value.
  /// Audited: 2026-06-12 11:26 EDT
  void removeByValue(V value) {
    final K? k = _reverse.remove(value);
    if (k != null) _forward.remove(k);
  }

  /// Number of key-value pairs.
  /// Audited: 2026-06-12 11:26 EDT
  int get length => _forward.length;

  @override
  String toString() => 'BimapUtils(length: ${_forward.length})';
}
