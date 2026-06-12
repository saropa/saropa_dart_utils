/// Generic synchronous cache interface + a write-through async adapter —
/// roadmap #523.
library;

// The interface methods name their parameters (key/value) deliberately: the
// names document the contract and are referenced from the dartdoc. They are
// "unused" only because an interface declaration has no body.
// ignore_for_file: prefer_wildcard_for_unused_param -- interface params name the contract

/// The common contract shared by the in-memory caches ([LruCache], [TtlCache],
/// [SizeLimitCache]): look up a key, store a value, clear everything.
///
/// Depending on this interface instead of a concrete class lets a call site
/// require "a cache" without committing to an eviction policy, so LRU, TTL, or
/// size-limited can be swapped without touching consumers. `null` from [get]
/// always means absent-or-expired, which is why the concrete caches constrain
/// `V` to a non-nullable type.
abstract interface class Cache<K, V> {
  /// Returns the value cached under [key], or null if absent or expired.
  /// Audited: 2026-06-12 11:26 EDT
  V? get(K key);

  /// Stores [value] under [key], applying this cache's eviction policy.
  /// Audited: 2026-06-12 11:26 EDT
  void set(K key, V value);

  /// Removes every entry.
  /// Audited: 2026-06-12 11:26 EDT
  void clear();
}

/// Wraps a synchronous [Cache] with an async [loader], turning a cache miss
/// into a single load whose result is stored (the read-through / write-through
/// pattern apps re-implement around every remote fetch).
///
/// Concurrent misses for the SAME key share one in-flight load rather than each
/// invoking [loader] — a thundering-herd guard. A load that throws is NOT
/// cached and the error propagates to every waiter; the next call retries.
/// Audited: 2026-06-12 11:26 EDT
// Expiration is the wrapped Cache's responsibility (pass a TtlCache to get it);
// this adapter only coordinates loads and intentionally has no TTL of its own.
// ignore: saropa_lints/require_cache_expiration -- delegated to the wrapped Cache
class WriteThroughCache<K, V extends Object> {
  /// Wraps [cache], filling misses by awaiting [loader].
  /// Audited: 2026-06-12 11:26 EDT
  WriteThroughCache(this._cache, this._loader);

  final Cache<K, V> _cache;
  final Future<V> Function(K key) _loader;
  final Map<K, Future<V>> _inFlight = <K, Future<V>>{};

  /// Returns the cached value for [key]; on a miss, loads it once via the
  /// loader, stores it, and returns it. Simultaneous misses for [key] await the
  /// same load.
  /// Audited: 2026-06-12 11:26 EDT
  Future<V> getOrLoad(K key) {
    final V? cached = _cache.get(key);
    if (cached != null) return Future<V>.value(cached);
    final Future<V>? pending = _inFlight[key];
    if (pending != null) return pending;
    final Future<V> load = _load(key);
    _inFlight[key] = load;
    return load;
  }

  Future<V> _load(K key) async {
    try {
      final V value = await _loader(key);
      _cache.set(key, value);
      return value;
    } finally {
      // Always clear the in-flight slot, success or failure, so a failed load
      // does not pin a permanently-rejected future and block later retries.
      // The returned in-flight future is intentionally discarded, not awaited.
      // ignore: avoid_unawaited_future -- clearing the slot, not awaiting it
      _inFlight.remove(key);
    }
  }
}
