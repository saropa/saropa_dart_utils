/// Cache with size limit (evict oldest). Roadmap #198.
///
/// Optional [ttl] expires entries after the given duration; expired entries
/// are treated as missing on [get].
class SizeLimitCache<K extends Object, V extends Object> {
  SizeLimitCache(int maxSize, {Duration? ttl})
    : _maxSize = maxSize,
      _ttl = ttl,
      assert(maxSize > 0);

  final int _maxSize;
  final Duration? _ttl;

  /// Maximum number of entries; oldest is evicted when exceeded.
  int get maxSize => _maxSize;
  final Map<K, V> _map = <K, V>{};
  final List<K> _order = <K>[];
  final Map<K, DateTime> _expiresAt = <K, DateTime>{};

  /// Returns the value for [key], or null. Returns null if expired (when the cache was created with a TTL).
  V? get(K key) {
    if (_ttl != null) {
      final DateTime? exp = _expiresAt[key];
      if (exp != null && DateTime.now().isAfter(exp)) {
        _order.remove(key);
        _map.remove(key);
        _expiresAt.remove(key);
        return null;
      }
    }
    return _map[key];
  }

  /// Associates [key] with [value]; evicts oldest entry if at capacity.
  void set(K key, V value) {
    if (_ttl != null) _expiresAt[key] = DateTime.now().add(_ttl);
    if (!_map.containsKey(key) && _order.length >= _maxSize) {
      final K evict = _order.removeAt(0);
      _map.remove(evict);
      _expiresAt.remove(evict);
    }
    if (!_order.contains(key)) _order.add(key);
    _map[key] = value;
  }

  /// Removes all entries.
  void clear() {
    _map.clear();
    _order.clear();
    _expiresAt.clear();
  }

  @override
  String toString() => 'SizeLimitCache(maxSize: $_maxSize, length: ${_map.length})';
}
