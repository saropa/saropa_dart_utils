/// LRU/LFU hybrid eviction cache — roadmap #480.
library;

// File-level rather than inline because the // ignore: on the class
// declaration is not honored for this rule by the analyzer plugin.
// ignore_for_file: require_cache_expiration -- bounded cache caps memory by [capacity] via eviction (no unbounded growth -> no OOM); TTL freshness is the caller's concern, not this primitive's contract

/// Internal per-key bookkeeping: how often the key was touched ([frequency])
/// and a monotonic tick of the last touch ([recency]). Kept private so the
/// scoring rule cannot be mutated from outside.
class _CacheEntry<V> {
  _CacheEntry(this.value, this.recency);
  V value;
  int frequency = 1;
  int recency;
}

/// Bounded cache that evicts the entry with the lowest access frequency,
/// breaking ties by least-recently-used (LFU primary, LRU tiebreaker).
///
/// WHY: plain LRU thrashes when a one-off scan touches many keys once; plain
/// LFU never ages out a key that was hot long ago. The hybrid keeps frequently
/// used keys and, among equally-frequent keys, drops the staler one. [get]
/// increments frequency and refreshes recency; [put] inserts/updates and evicts
/// the single lowest-scoring victim when over [capacity]. A [capacity] of 0
/// stores nothing (every [put] is a no-op).
///
/// Example:
/// ```dart
/// final cache = LruLfuCacheUtils<String, int>(2);
/// cache.put('a', 1);
/// cache.put('b', 2);
/// cache.get('a'); // 'a' now has frequency 2
/// cache.put('c', 3); // evicts 'b' (frequency 1, least used)
/// cache.get('b'); // null
/// cache.get('a'); // 1
/// ```
class LruLfuCacheUtils<K, V> {
  /// Creates a cache holding at most [capacity] entries. Throws an
  /// [ArgumentError] when [capacity] is negative; a [capacity] of 0 is allowed
  /// and stores nothing.
  factory LruLfuCacheUtils(int capacity) {
    // Validate in the factory so a negative capacity never yields a
    // partially-constructed object with corrupt invariants.
    if (capacity < 0) throw ArgumentError.value(capacity, 'capacity', 'must be >= 0');
    return LruLfuCacheUtils<K, V>._(capacity);
  }

  LruLfuCacheUtils._(this.capacity);

  /// Maximum number of entries retained; excess entries are evicted on [put].
  final int capacity;

  final Map<K, _CacheEntry<V>> _entries = <K, _CacheEntry<V>>{};

  // Monotonic counter stamped on every touch so recency comparisons never tie
  // unless two entries were literally never re-touched after the same insert.
  int _tick = 0;

  /// Number of entries currently held (0 to [capacity]).
  int get length => _entries.length;

  /// Returns the value for [key], updating its recency and frequency, or null
  /// when absent. A miss does not create an entry, so it never affects scoring.
  V? get(K key) {
    final _CacheEntry<V>? entry = _entries[key];
    if (entry == null) return null;
    entry.frequency++;
    entry.recency = ++_tick;
    return entry.value;
  }

  /// Inserts or updates [key] with [value]. Updating an existing key bumps its
  /// recency and frequency like [get]; inserting a new key past [capacity]
  /// evicts the lowest-scoring victim first.
  void put(K key, V value) {
    // Capacity 0 stores nothing: skip the bookkeeping entirely rather than
    // insert-then-immediately-evict, which would needlessly churn the tick.
    if (capacity == 0) return;
    final _CacheEntry<V>? existing = _entries[key];
    if (existing != null) {
      existing.value = value;
      existing.frequency++;
      existing.recency = ++_tick;
      return;
    }
    if (_entries.length >= capacity) _evict();
    _entries[key] = _CacheEntry<V>(value, ++_tick);
  }

  /// Removes [key] and returns its value, or null when it was not present.
  V? remove(K key) => _entries.remove(key)?.value;

  // Drops the single worst entry: lowest frequency, then lowest recency among
  // ties. firstOrNull-style guard avoids reduce on an empty map; callers only
  // reach here when at capacity, but the explicit null check documents intent.
  void _evict() {
    K? victimKey;
    _CacheEntry<V>? victim;
    for (final MapEntry<K, _CacheEntry<V>> e in _entries.entries) {
      if (victim == null || _lessThan(e.value, victim)) {
        victimKey = e.key;
        victim = e.value;
      }
    }
    if (victimKey != null) _entries.remove(victimKey);
  }

  // True when [a] should be evicted before [b]: strictly lower frequency, or
  // equal frequency with strictly older recency (least-recently-used wins ties).
  bool _lessThan(_CacheEntry<V> a, _CacheEntry<V> b) {
    if (a.frequency != b.frequency) return a.frequency < b.frequency;
    return a.recency < b.recency;
  }

  @override
  String toString() => 'LruLfuCacheUtils(capacity: $capacity, length: ${_entries.length})';
}
