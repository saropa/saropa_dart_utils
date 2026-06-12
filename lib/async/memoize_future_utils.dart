import 'package:saropa_dart_utils/async/async_semaphore_utils.dart' show AsyncAction;

/// Cache single async result (memoize Future). Returns a function that runs
/// [fn] once and reuses the same Future. Roadmap #180.
///
/// CAVEAT: the result is cached unconditionally, INCLUDING a failure. If [fn]'s
/// future rejects, every later call returns that same rejected future — the
/// operation is never retried. Use a retrying helper (e.g. the idempotent-run
/// utility, which evicts on completion) when failures should be retried.
/// Audited: 2026-06-12 11:26 EDT
Future<T> Function() memoizeFuture<T>(AsyncAction<T> fn) {
  Future<T>? cached;
  return () async {
    final future = cached ??= fn();
    return await future;
  };
}
