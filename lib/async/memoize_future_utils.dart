/// Supplier of a single async result (memoized).
typedef FutureSupplier<T> = Future<T> Function();

/// Cache single async result (memoize Future). Returns a function that runs [fn] once and reuses the same Future. Roadmap #180.
Future<T> Function() memoizeFuture<T>(FutureSupplier<T> fn) {
  Future<T>? cached;
  return () async {
    final future = cached ??= fn();
    return await future;
  };
}
