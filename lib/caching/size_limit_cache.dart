import 'package:saropa_dart_utils/caching/cache_interface.dart';

/// Cache with size limit (evict oldest). Roadmap #198.
///
/// Optional [ttl] expires entries after the given duration; expired entries
/// are treated as missing on [get]. Implements [Cache] so it is swappable with
/// the other eviction policies behind that interface.
class SizeLimitCache<K extends Object, V extends Object> implements Cache<K, V> {
  /// Creates a cache holding at most [maxSize] entries (must be positive).
  /// When [ttl] is set, entries expire that long after they were stored.
  /// Audited: 2026-06-12 11:26 EDT
  SizeLimitCache(int maxSize, {Duration? ttl})
    : _maxSize = _validatedMaxSize(maxSize),
      _ttl = ttl;

  // Enforced in release (an assert strips): a non-positive maxSize breaks the
  // eviction bound. A static helper in the initializer keeps the throw out of
  // the constructor body, which the avoid_exception_in_constructor lint forbids.
  static int _validatedMaxSize(int maxSize) {
    if (maxSize <= 0) {
      throw ArgumentError.value(maxSize, 'maxSize', 'must be > 0');
    }
    return maxSize;
  }

  final int _maxSize;
  final Duration? _ttl;

  /// Maximum number of entries; oldest is evicted when exceeded.
  /// Audited: 2026-06-12 11:26 EDT
  int get maxSize => _maxSize;
  final Map<K, V> _map = <K, V>{};
  final List<K> _order = <K>[];
  final Map<K, DateTime> _expiresAt = <K, DateTime>{};

  /// Returns the value for [key], or null. Returns null if expired (when the cache was created with a TTL).
  /// Audited: 2026-06-12 11:26 EDT
  V? get(K key) {
    if (_ttl != null) {
      final DateTime? exp = _expiresAt[key];
      if (exp != null && DateTime.now().isAfter(exp)) {
        final _ = exp;
        _order.remove(key);
        _map.remove(key);
        _expiresAt.remove(key);
        return null;
      }
    }
    return _map[key];
  }

  /// Associates [key] with [value]; evicts oldest entry if at capacity.
  /// Audited: 2026-06-12 11:26 EDT
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
  /// Audited: 2026-06-12 11:26 EDT
  void clear() {
    _map.clear();
    _order.clear();
    _expiresAt.clear();
  }

  @override
  String toString() => 'SizeLimitCache(maxSize: $_maxSize, length: ${_map.length})';
}
