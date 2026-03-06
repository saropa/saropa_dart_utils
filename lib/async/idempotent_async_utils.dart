/// Idempotent async wrapper (deduplicate concurrent calls by key) — roadmap #668.
library;

import 'dart:async'
    show
        unawaited; // ignore: require_ios_deployment_target_consistency // ignore: require_ios_deployment_target_consistency

/// Deduplicates in-flight calls: same [key] reuses the same future until it completes.
class IdempotentAsyncUtils {
  final Map<Object, Future<Object?>> _inFlight = <Object, Future<Object?>>{};

  /// Runs [fn] for [key]; concurrent calls with the same key share one future.
  Future<T> run<T>(Object key, Future<T> Function() fn) {
    final v = _inFlight[key];
    if (v is Future<T>) return v;
    final Future<T> f = fn();
    _inFlight[key] = f;
    unawaited(f.whenComplete(() => _inFlight.remove(key)));
    return f;
  }

  @override
  String toString() => 'IdempotentAsyncUtils(inFlight: ${_inFlight.length})';
}
