/// MRU (most-recently-used) cache with access-frequency tracking — roadmap #509.
///
/// An MRU cache evicts the *most* recently used entry when full — the opposite
/// of LRU. This is the right policy for cyclic or single-pass scans (looping
/// over a dataset larger than the cache): the item just touched is the one
/// least likely to be needed again soon, while older entries near the start of
/// the cycle will be revisited first. Under such access patterns MRU beats LRU,
/// which would otherwise evict exactly the entries about to be reused.
///
/// Alongside eviction it tracks a per-key access count ([frequencyOf]), useful
/// for hotspot detection and cache-tuning telemetry. Frequencies persist for as
/// long as the key stays resident and reset when it is evicted or removed.
library;

// ignore_for_file: require_cache_expiration -- bounded cache caps memory by [capacity] via MRU eviction (no unbounded growth); TTL freshness is the caller's concern, not this primitive's contract.

/// A fixed-capacity cache using most-recently-used eviction.
class MruCache<K, V> {
  /// Creates a cache holding at most [capacity] entries. Requires
  /// `capacity > 0`.
  MruCache(int capacity)
    : assert(capacity > 0, 'capacity ($capacity) must be > 0'),
      _capacity = capacity;

  final int _capacity;
  final Map<K, V> _values = <K, V>{};
  // Access recency, least-recent first; the last element is the MRU entry that
  // eviction targets. Kept in sync with [_values] on every touch.
  final List<K> _recency = <K>[];
  final Map<K, int> _frequency = <K, int>{};

  /// Number of entries currently cached.
  int get length => _values.length;

  /// Returns the value for [key] (or null), counting the access and marking the
  /// key most-recently-used.
  ///
  /// Example:
  /// ```dart
  /// final MruCache<String, int> c = MruCache<String, int>(2)
  ///   ..put('a', 1)
  ///   ..put('b', 2);
  /// c.put('c', 3); // full: evicts 'b' (the MRU), keeps 'a'
  /// c.get('a'); // 1
  /// ```
  V? get(K key) {
    if (!_values.containsKey(key)) return null;
    _touch(key);
    return _values[key];
  }

  /// Inserts or updates [key] with [value]. When the cache is full and [key] is
  /// new, the most-recently-used entry is evicted to make room.
  void put(K key, V value) {
    if (!_values.containsKey(key) && _values.length >= _capacity) _evictMru();
    _values[key] = value;
    _touch(key);
  }

  /// Number of times [key] has been accessed (via [get] or [put]) while
  /// resident; `0` if never seen or since evicted.
  int frequencyOf(K key) => _frequency[key] ?? 0;

  /// Removes [key] and its frequency, if present.
  void remove(K key) {
    _values.remove(key);
    _recency.remove(key);
    _frequency.remove(key);
  }

  // Marks [key] as most-recently-used and increments its access count.
  void _touch(K key) {
    _recency
      ..remove(key)
      ..add(key);
    _frequency[key] = (_frequency[key] ?? 0) + 1;
  }

  // Evicts the most-recently-used entry (tail of the recency list).
  void _evictMru() {
    if (_recency.isEmpty) return;
    final K victim = _recency.removeLast();
    _values.remove(victim);
    _frequency.remove(victim);
  }

  @override
  String toString() => 'MruCache(length: ${_values.length}/$_capacity)';
}
