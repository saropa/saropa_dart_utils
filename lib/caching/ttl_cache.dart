import 'package:saropa_dart_utils/caching/cache_interface.dart';

/// TTL cache (expire after duration). Roadmap #195.
///
/// Implements [Cache] so it is swappable with the other eviction policies
/// behind that interface.
class TtlCache<K extends Object, V extends Object> implements Cache<K, V> {
  /// Creates a cache whose entries each expire [ttl] after being stored.
  TtlCache(Duration ttl) : _ttl = ttl;

  final Duration _ttl;

  /// Time-to-live for each entry; expired entries return null from [get].
  Duration get ttl => _ttl;
  final Map<K, (V, DateTime)> _map = <K, (V, DateTime)>{};

  /// Returns the value for [key] if not expired, or null.
  V? get(K key) {
    final (V, DateTime)? entry = _map[key];
    if (entry == null) return null;
    if (DateTime.now().isAfter(entry.$2)) {
      _map.remove(key);
      return null;
    }
    return entry.$1;
  }

  /// Stores [value] under [key] with a fresh expiry [ttl] from now.
  void set(K key, V value) {
    _map[key] = (value, DateTime.now().add(_ttl));
  }

  /// Removes all entries.
  void clear() => _map.clear();

  @override
  String toString() => 'TtlCache(ttl: $_ttl, length: ${_map.length})';
}
