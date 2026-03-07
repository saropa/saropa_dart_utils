import 'package:saropa_dart_utils/async/async_semaphore_utils.dart'
    show AsyncAction;

/// Cache single async result (memoize Future). Returns a function that runs [fn] once and reuses the same Future. Roadmap #180.
Future<T> Function() memoizeFuture<T>(AsyncAction<T> fn) {
  Future<T>? cached;
  return () async {
    final future = cached ??= fn();
    return await future;
  };
}
