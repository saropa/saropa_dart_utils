/// Memoize sync function (by argument equality). Single-value cache. Roadmap #196, #197.
V Function(A) memoize1<A, V>(V Function(A) fn) {
  final Map<A, V> cache = <A, V>{};
  return (A a) => cache.putIfAbsent(a, () => fn(a));
}

/// Returns a function that computes once and returns cached value.
///
/// A `null` result is cached too: a `computed` flag (not `??=`) gates the call,
/// so a `null`-returning [compute] still runs only once.
T Function() singleValueCache<T>(T Function() compute) {
  bool computed = false;
  late T cached;
  return () {
    if (!computed) {
      cached = compute();
      computed = true;
    }
    return cached;
  };
}
