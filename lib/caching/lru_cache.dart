/// LRU cache (max size, pure Dart). Roadmap #194.
///
/// Optional [ttl] expires entries after the given duration; expired entries
/// are treated as missing on [get].
class LruCache<K extends Object, V extends Object> {
  LruCache(int maxSize, {Duration? ttl}) : _maxSize = maxSize, _ttl = ttl, assert(maxSize > 0);

  final int _maxSize;
  final Duration? _ttl;

  /// Maximum number of entries; oldest is evicted when exceeded.
  int get maxSize => _maxSize;
  final Map<K, V> _map = <K, V>{};
  final List<K> _order = <K>[];
  final Map<K, DateTime> _expiresAt = <K, DateTime>{};

  /// Returns the value for [key], or null; promotes [key] to most recently used.
  /// Returns null if the entry has expired (when the cache was created with a TTL).
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
    final V? v = _map[key];
    if (v == null) return null;
    _order.remove(key);
    _order.add(key);
    return v;
  }

  /// Associates [key] with [value]; evicts oldest entry if at capacity.
  void set(K key, V value) {
    if (_ttl != null) _expiresAt[key] = DateTime.now().add(_ttl);
    if (_map.containsKey(key)) {
      _order.remove(key);
    } else if (_order.length >= _maxSize) {
      final K evict = _order.removeAt(0);
      _map.remove(evict);
      _expiresAt.remove(evict);
    }
    _map[key] = value;
    _order.add(key);
  }

  void clear() {
    _map.clear();
    _order.clear();
    _expiresAt.clear();
  }

  /// Current number of entries.
  int get length => _map.length;

  @override
  String toString() => 'LruCache(maxSize: $_maxSize, length: ${_map.length})';
}
