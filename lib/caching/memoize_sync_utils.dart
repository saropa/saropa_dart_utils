/// Memoize sync function (by argument equality). Single-value cache. Roadmap #196, #197.
V Function(A) memoize1<A, V>(V Function(A) fn) {
  final Map<A, V> cache = <A, V>{};
  return (A a) {
    return cache.putIfAbsent(a, () => fn(a));
  };
}

/// Returns a function that computes once and returns cached value.
T Function() singleValueCache<T>(T Function() compute) {
  T? cached;
  return () => cached ??= compute();
}
