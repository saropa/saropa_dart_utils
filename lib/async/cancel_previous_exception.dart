/// Returns a wrapper that cancels previous in-flight calls when invoked again; the superseded future throws [CancelPreviousException]. Roadmap #183.
Future<T> Function() cancelPrevious<T>(Future<T> Function() fn) {
  int generation = 0;
  return () async {
    final int myGen = ++generation;
    final T result = await fn();
    if (myGen != generation) throw CancelPreviousException();
    return result;
  };
}

/// Thrown when a call was superseded by a newer [cancelPrevious] invocation.
class CancelPreviousException implements Exception {}
