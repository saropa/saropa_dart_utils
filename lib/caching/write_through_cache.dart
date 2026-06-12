/// Write-through and write-back caches over async loaders — roadmap #508.
///
/// Both wrap an async backing store (a remote API, a database, a file) behind
/// an in-memory map so repeated reads of the same key are served locally, and
/// both coordinate *writes* to that store — the capability the read-through
/// [WriteThroughCache] (roadmap #523) does not provide. They differ only in
/// *when* writes reach the backing store:
///
/// - [WriteThroughStore] writes synchronously to the store on every `put`, so
///   the store is always current and a crash loses nothing — at the cost of one
///   round-trip per write.
/// - [WriteBackStore] buffers writes in memory and only persists them on
///   [WriteBackStore.flush], coalescing repeated writes to the same key into
///   one store call — faster under write-heavy load, but unflushed entries are
///   lost on a crash.
///
/// Neither evicts on its own; pair with a size-bounded map (see `lru_cache`) if
/// the key space is unbounded.
library;

// ignore_for_file: require_cache_expiration -- these wrap a backing store; data freshness (TTL) is the loader's / caller's concern, and unbounded growth is bounded by pairing with a size-limited map as documented above, not by this primitive's contract.

/// Loads the value for a key from the backing store (null = absent).
typedef CacheLoader<K, V> = Future<V?> Function(K key);

/// Persists a key/value pair to the backing store.
typedef CacheStorer<K, V> = Future<void> Function(K key, V value);

/// A cache that persists every write to the backing store immediately.
class WriteThroughStore<K, V> {
  /// Creates a cache backed by [load] (read-through on a miss) and [store]
  /// (called on every [put] before the in-memory entry is updated).
  WriteThroughStore({required CacheLoader<K, V> load, required CacheStorer<K, V> store})
    : _load = load,
      _store = store;

  final CacheLoader<K, V> _load;
  final CacheStorer<K, V> _store;
  final Map<K, V> _cache = <K, V>{};

  /// Returns the cached value, loading and caching it on a miss. A backing
  /// store that returns null is treated as "absent" and is not cached.
  Future<V?> get(K key) async {
    if (_cache.containsKey(key)) return _cache[key];
    final V? loaded = await _load(key);
    if (loaded != null) _cache[key] = loaded;
    return loaded;
  }

  /// Persists [value] to the store, then updates the in-memory entry. The
  /// store write is awaited first so a failed write leaves the cache unchanged.
  Future<void> put(K key, V value) async {
    await _store(key, value);
    _cache[key] = value;
  }

  /// Drops the in-memory entry for [key] without touching the backing store.
  void invalidate(K key) => _cache.remove(key);

  /// Number of entries currently held in memory.
  int get length => _cache.length;
}

/// A cache that buffers writes in memory until [flush] persists them.
class WriteBackStore<K, V> {
  /// Creates a cache backed by [load] (read-through on a miss) and [store]
  /// (called once per dirty key during [flush]).
  WriteBackStore({required CacheLoader<K, V> load, required CacheStorer<K, V> store})
    : _load = load,
      _store = store;

  final CacheLoader<K, V> _load;
  final CacheStorer<K, V> _store;
  final Map<K, V> _cache = <K, V>{};
  // Keys whose in-memory value has not yet reached the backing store.
  final Set<K> _dirty = <K>{};

  /// Returns the cached value, loading and caching it on a miss.
  Future<V?> get(K key) async {
    if (_cache.containsKey(key)) return _cache[key];
    final V? loaded = await _load(key);
    if (loaded != null) _cache[key] = loaded;
    return loaded;
  }

  /// Updates the in-memory entry and marks it dirty; the store is untouched
  /// until [flush]. Repeated puts to one key collapse into a single later write.
  void put(K key, V value) {
    _cache[key] = value;
    _dirty.add(key);
  }

  /// Keys with buffered writes not yet persisted (an unmodifiable snapshot).
  Set<K> get dirtyKeys => Set<K>.unmodifiable(_dirty);

  /// Persists every dirty entry to the backing store and clears the dirty set.
  /// A store failure aborts the flush; already-written keys stay clean, the
  /// failing key and any after it remain dirty for the next attempt.
  Future<void> flush() async {
    // Iterate cache entries (typed V, no cast) filtered to the dirty set, and
    // snapshot to a list so a concurrent put during the awaits is not lost.
    final List<MapEntry<K, V>> pending = <MapEntry<K, V>>[
      for (final MapEntry<K, V> e in _cache.entries)
        if (_dirty.contains(e.key)) e,
    ];
    for (final MapEntry<K, V> e in pending) {
      await _store(e.key, e.value);
      _dirty.remove(e.key);
    }
  }

  /// Number of entries currently held in memory.
  int get length => _cache.length;
}
